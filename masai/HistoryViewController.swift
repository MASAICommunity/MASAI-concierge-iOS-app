//
//  HistoryViewController.swift
//  masai
//
//  Created by Florian Rath on 16.11.17.
//  Copyright © 2017 5lvlup gmbh. All rights reserved.
//

import UIKit
import PromiseKit


class HistoryViewController: MasaiBaseViewController {
    
    // MARK: Types
    
    enum State {
        case empty
        case loading(keepTableViewVisible: Bool)
        case showHistory
    }
    
    
    // MARK: Properties
    
    private var searchTerm: String?
    private var unfilteredChannels: [Channel] = []
    fileprivate var channels: [Channel] = []
    fileprivate var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    private var state: State = .empty {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.updateUIForState()
            }
        }
    }
    
    
    // MARK: UI
    
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var loadingIndicator: LoadingIndicator!
    private var emptyStateLabel: UILabel!
    private var filterView: HistoryFilterView!
    
    private var filterContentViewCollapsedConstraints: [NSLayoutConstraint] = []
    private var filterContentViewExpandedConstraints: [NSLayoutConstraint] = []
    private var filterContentViewIsExpanded = false
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        reloadChannels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIForState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Public
    
    func reloadHistory() {
        reloadChannels()
    }
    
    
    // MARK: Setup
    
    private func setup() {
        tabBarItem.image = #imageLiteral(resourceName: "tab-history")
        
        if tableView == nil {
            tableView = UITableView()
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tableView)
            tableView.pinEdges(to: view).activate()
            
            tableView.register(UINib(nibName: ConversationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ConversationTableViewCell.identifier)
        }
    
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "pull_to_refresh".localized)
            refreshControl.addTarget(self, action: #selector(self.pullToRefresh(_:)), for: .valueChanged)
            tableView.addSubview(refreshControl)
        }
        
        if emptyStateLabel == nil {
            emptyStateLabel = UILabel()
            emptyStateLabel.font = UIFont.systemFont(ofSize: 12)
            emptyStateLabel.numberOfLines = 0
            emptyStateLabel.textAlignment = .center
            emptyStateLabel.text = "history_empty_state".localized
            emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(emptyStateLabel)
            emptyStateLabel.pinCenter(to: view).activate()
            emptyStateLabel.pin.edges([.leading, .trailing]).to(view).with(constants: [16, -16]).activate()
        }
        
        if loadingIndicator == nil {
            loadingIndicator = LoadingIndicator()
            loadingIndicator.setup(in: view)
            loadingIndicator.setBehaviourBeforeStart { [unowned self] in
                self.tableView.isUserInteractionEnabled = false
            }
            loadingIndicator.setBehaviourAfterStop { [unowned self] in
                self.tableView.isUserInteractionEnabled = true
            }
        }
        
        if filterView == nil {
            filterView = HistoryFilterView()
            filterView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(filterView)
            filterView.pin.edges([.leading, .trailing]).to(view).activate()
            filterContentViewCollapsedConstraints.append(contentsOf: filterView.pin.bottom.to(view.topAnchor).constraints)
            filterContentViewExpandedConstraints.append(contentsOf: filterView.pin.top.to(view).constraints)
            filterContentViewCollapsedConstraints.activate()
            
            filterView.textSearchedClosure = { [unowned self] (searchTerm: String?) in
                self.expandFilterView(false)
                
                guard let term = searchTerm else {
                    self.clearFilter()
                    return
                }
                
                self.searchTerm = term
                self.channels = self.unfilteredChannels.filter { $0.contains(searchTerm: term) }
                self.tableView.reloadData()
                
                if self.channels.count == 0 {
                    self.state = .empty
                } else {
                    self.state = .showHistory
                }
            }
            
            filterView.dateSearchedClosure = { [unowned self] (searchDate: Date?) in
                self.expandFilterView(false)
                
                guard let date = searchDate else {
                    self.clearFilter()
                    return
                }
                
                self.searchTerm = nil
                self.channels = self.unfilteredChannels.filter { $0.contains(date: date) }
                self.tableView.reloadData()
                
                if self.channels.count == 0 {
                    self.state = .empty
                } else {
                    self.state = .showHistory
                }
            }
        }
    }
    
    
    // MARK: UI events
    
    @objc private func pullToRefresh(_ sender: UIRefreshControl) {
        reloadChannels()
    }
    
    
    // MARK: Private
    
    fileprivate func reloadChannels() {
        filterView.clearFilters()
        
        state = .loading(keepTableViewVisible: refreshControl.isRefreshing)
        
        channels = HostConnectionManager.shared.archivedChannels()
        
        let promises = channels.flatMap { (channel: Channel) -> Promise<Void>? in
            guard let sm = HostConnectionManager.shared.socketManager(for: channel) else {
                return nil
            }
            return sm.loadHistory(for: channel)
        }
        
        var updatedChannels = channels
        firstly {
            when(resolved: promises)
            }
            .then(on: DispatchQueue.main, execute: { [unowned self] (results: [Result<Void>]) -> Void in
                for result in results {
                    switch result {
                    case .fulfilled(_):
                        continue
                    case let .rejected(error):
                        switch error {
                        case let HistoryError.invalidRoom(roomId):
                            updatedChannels = updatedChannels.filter { $0.roomId != roomId }
                        //TODO: Remove channel from HostConnectionManager (or UserDefaults), since we cannot get history for them
                        default:
                            continue
                        }
                    }
                }
                
                self.unfilteredChannels = updatedChannels.sorted(by: { (c1, c2) -> Bool in
                    let beginDate1 = c1.firstMessage()?.date ?? Date()
                    let beginDate2 = c2.firstMessage()?.date ?? Date()
                    return beginDate2 < beginDate1
                })
                self.clearFilter()
                
                if self.channels.count > 0 {
                    self.state = .showHistory
                } else {
                    self.state = .empty
                }
            })
            .catch(on: DispatchQueue.main, policy: CatchPolicy.allErrors, execute: { [unowned self] error in
                self.tableView.reloadData()
                if self.channels.count > 0 {
                    self.state = .showHistory
                } else {
                    self.state = .empty
                }
            })
    }
    
    fileprivate func openChatView(for channel: Channel) {
        state = .loading(keepTableViewVisible: true)
        
        let chatVC = ChatViewController()
        chatVC.setup(with: channel) { [unowned self] (didSucceed: Bool) in
            guard didSucceed == true else {
                AlertManager.showError("errorFatal".localized, controller: self)
                self.loadingIndicator.stopAnimating()
                return
            }
            
            self.state = .showHistory
            
            chatVC.searchTerm = self.searchTerm
            
            chatVC.displayType = .history
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    private func updateUIForState() {
        switch state {
        case .empty:
            emptyStateLabel.alpha = 1.0
            tableView.alpha = 0.0
            loadingIndicator.stopAnimating()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            
        case let .loading(keepTableViewVisible):
            emptyStateLabel.alpha = 0.0
            if !keepTableViewVisible {
                tableView.alpha = 0.0
                loadingIndicator.startAnimating()
            }
            
        case .showHistory:
            emptyStateLabel.alpha = 0.0
            tableView.alpha = 1.0
            loadingIndicator.stopAnimating()
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    private func expandFilterView(_ shouldExpand: Bool) {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            if self.filterContentViewIsExpanded {
                self.filterContentViewExpandedConstraints.deactivate()
                self.filterContentViewCollapsedConstraints.activate()
            } else {
                self.filterContentViewCollapsedConstraints.deactivate()
                self.filterContentViewExpandedConstraints.activate()
            }
            self.view.layoutIfNeeded()
            self.filterContentViewIsExpanded = shouldExpand
        }
    }
    
    private func clearFilter() {
        searchTerm = nil
        channels = unfilteredChannels
        tableView.reloadData()
        
        if channels.count > 0 {
            state = .showHistory
        } else {
            state = .empty
        }
    }
    
    
    // MARK: MasaiBaseViewController
    
    override func isNavigationBarVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBar() -> String? {
        return "history_title".localized
    }
    
    override func isNavigationBarRightItemVisible() -> Bool {
        return true
    }
    
    override func imageForNavigationBarRightItem() -> UIImage? {
        return #imageLiteral(resourceName: "icon-filter")
    }
    
    override func onPressedNavigationBarRightButton() {
        expandFilterView(!filterContentViewIsExpanded)
    }
}


// MARK: UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let channel = channels.get(index: indexPath.row) {
            openChatView(for: channel)
        } else {
            self.reloadChannels()
        }
    }
    
}


// MARK: UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConversationTableViewCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier) as! ConversationTableViewCell
        guard let channel = channels.get(index: indexPath.row) else {
            return cell
        }
        
        cell.lastMessageDateLabel.text = ""
        
        if let lastMessage = channel.lastMessage(),
            let lastUpdateDate = lastMessage.updated,
            let firstMessage = channel.firstMessage(),
            let firstUpdateDate = firstMessage.updated {
            cell.lastMessageLabel.text = "\(dateFormatter.string(from: firstUpdateDate)) - \(dateFormatter.string(from: lastUpdateDate))"
        } else {
            cell.lastMessageLabel.text = ""
        }
        
        if let host = HostConnectionManager.shared.cachedActiveHost(for: channel) {
            cell.avatarLabel.text = host.name.substring(to: 2).uppercased()
            cell.nameLabel.text = host.name
        } else {
            cell.avatarLabel.text = "CH"
            cell.nameLabel.text = "history_title".localized
        }
        
        return cell
    }
    
}
