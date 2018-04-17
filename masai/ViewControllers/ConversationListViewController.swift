//
//  MainViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

class ConversationListViewController: MasaiBaseViewController {
    
    // MARK: UI
    
    @IBOutlet weak var addConversationButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    private var loadingIndicator = LoadingIndicator()
    
    
    // MARK: Properties
    
    var selectedRoomId: String?
    var refreshTimer: Timer?
    var isFirstOpen = true
    let uniqueSubsriptionIdentifier = String.random(length: 50)
    var channels: [Channel] = [] {
        didSet {
            showEmptyState(channels.count == 0)
            self.reloadTableView()
        }
    }
    private var notificationTokens: [Notification.NotificationToken] = []
    var pushRequest: PushOpenChatRequest?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        registerCellForTableView()
        
        loadingIndicator.setup(in: view)
        loadingIndicator.setBehaviourBeforeStart { [unowned self] in
            self.tableView.isUserInteractionEnabled = false
            self.addConversationButton.isUserInteractionEnabled = false
        }
        loadingIndicator.setBehaviourAfterStop { [unowned self] in
            self.tableView.isUserInteractionEnabled = true
            self.addConversationButton.isUserInteractionEnabled = true
        }
        
        notificationTokens.append(Constants.Notification.closeChannel.observe(eventClosure: { (_: Notification) in
            self.reloadChannels()
        }))
        
        notificationTokens.append(Constants.Notification.historyLoaded.observe(eventClosure: { (note: Notification) in
            guard let userInfo = note.userInfo,
                let channel = userInfo["channel"] as? Channel else {
                    return
            }
            if channel.isClosed == false {
                self.reloadTableView()
            }
        }))
        
        notificationTokens.append(Constants.Notification.socketConnected.observe(eventClosure: { (_: Notification) in
            self.reloadChannels()
        }))
        
        notificationTokens.append(Constants.Notification.newChannelFound.observe(eventClosure: { (_: Notification) in
            self.reloadChannels()
        }))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.reloadTableView), userInfo: nil, repeats: true)
        
        reloadChannels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if channels.isEmpty && isFirstOpen {
            openNewChatScreen()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isFirstOpen = false
        if let timer = self.refreshTimer {
            timer.invalidate()
        }
        removeSubscriptions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        for token in notificationTokens {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    
    // MARK: MasaiBaseViewController
    
    override func isNavigationBarVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBar() -> String? {
        return "conversationListViewControllerTitle".localized
    }
    
    
    // MARK: UI events
    
    @IBAction func onAddConversationButtonPressed(_ sender: Any) {
        openNewChatScreen()
    }
    
    
    // MARK: Private
    
    @objc fileprivate func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func registerCellForTableView() {
        tableView.register(UINib(nibName: ConversationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: ConversationTableViewCell.identifier)
    }
    
    private func prepareLayout() {
        self.addConversationButton.layer.shadowColor = UIColor.gray.cgColor
        self.addConversationButton.layer.shadowOpacity = 0.8
        self.addConversationButton.layer.shadowOffset = .zero
        self.addConversationButton.layer.shadowRadius = 10
        self.addConversationButton.setTitle("new_chat_button_title".localized, for: .normal)
        
        emptyStateLabel.text = "conversation_empty_state_text".localized
        showEmptyState(false)
    }
    
    private func refreshSubsriptions() {
        for channel in channels {
            guard let host = HostConnectionManager.shared.cachedActiveHost(for: channel) else {
                continue
            }
            
            let sm = HostConnectionManager.shared.socketManager(for: host)
            if sm == nil {
                HostConnectionManager.shared.connectTo(host: host)
                    .then { [unowned self] (socketManager: SocketManager) in
                        self.refresh(channel: channel)
                    }.catch { (error: Error) in
                        AlertManager.showError("serverConnectError".localized, controller: self)
                }
            } else {
                refresh(channel: channel)
            }
        }
    }
    
    private func refresh(channel: Channel) {
        HostConnectionManager.shared.socketManager(for: channel) { [unowned self] (sm: SocketManager?) in
            guard let socketManager = sm else {
                return
            }
            
            socketManager.subscribe(channel: channel, delegate: self)
            socketManager.resentUnsentMessages([channel])
            socketManager.loadHistory(for: channel)
            
            self.reloadTableView()
        }
    }
    
    private func removeSubscriptions() {
        let savedChannels = channels
        self.channels = []
        
        for channel in savedChannels {
            guard let socketManager = HostConnectionManager.shared.socketManager(for: channel) else {
                continue
            }
            socketManager.unsubscribe(channel: channel, delegate: self)
        }
    }
    
    private func openNewChatScreen() {
        let selectHostViewController = SelectHostViewController()
        let navigationController =  BaseNavigationController(rootViewController: selectHostViewController)
        selectHostViewController.selectCompletionBlock = {[weak self](selectedHost) in
            DispatchQueue.main.async {
                self?.onConversationHostSelected(host: selectedHost)
            }
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    private func selectOrCreateChannel(for host: Host) {
        HostConnectionManager.shared.getActiveHosts { [unowned self] (hosts: [Host]) in
            let filteredHosts = hosts.filter { $0 == host }
            var foundHost: Host
            if filteredHosts.count > 0 {
                foundHost = filteredHosts[0]
            } else {
                foundHost = host
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.channels = foundHost.channels.filter { $0.isClosed == false }
                
                if let channel = self.channels.get(index: 0) {
                    self.openChatView(for: channel)
                } else {
                    self.createConversation(for: foundHost)
                }
            }
        }
    }
    
    private func onConversationHostSelected(host: Host) {
        loadingIndicator.startAnimating()
        
        if let _ = HostConnectionManager.shared.socketManager(for: host) {
            selectOrCreateChannel(for: host)
        } else {
            HostConnectionManager.shared.connectTo(host: host)
                .then { (socketManager: SocketManager) -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [unowned self] in
                        self.selectOrCreateChannel(for: host)
                    })
                }.catch { (error: Error) in
                    AlertManager.showError("serverConnectError".localized, controller: self)
            }
        }
    }
    
    private func createConversation(for host: Host) {
        guard let socketManager = HostConnectionManager.shared.socketManager(for: host) else {
            AlertManager.showError("errorFatal".localized, controller: self)
            loadingIndicator.stopAnimating()
            return
        }
        
        socketManager.registerToLiveChat { [unowned self] (response, newChannel, credentials) in
            guard let channel = newChannel,
                let credentials = credentials else {
                    AlertManager.showError("liveChatError".localized, controller: self)
                    self.loadingIndicator.stopAnimating()
                    return
            }
            
            let tuple = HostConnectionManager.shared.update(credentials: credentials, for: host)
            
            HostConnectionManager.shared.addOrReplace(channel: channel, to: tuple.updatedHost)
            
            self.addConversation(with: tuple.updatedHost, channel: channel)
        }
    }
    
    private func addConversation(with host: Host, channel: Channel) {
        // If conversation already exists, we'll open the chat view for it
        for localChannel in channels where localChannel == channel {
            openChatView(for: localChannel)
            return
        }
        
        // Conversation does not exist, so we'll create it
        HostConnectionManager.shared.connectTo(host: host)
            .then { [unowned self] (socketManager: SocketManager) -> Void in
                HostConnectionManager.shared.addOrReplace(channel: channel, to: host)
                
                socketManager.subscribe(channel: channel, delegate: self)
                
                self.reloadChannels()
                
                self.refresh(channel: channel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
                    self.openChatView(for: channel)
                })
            }.catch { (error: Error) in
                AlertManager.showError("errorFatal".localized, controller: self)
        }
    }
    
    fileprivate func openChatView(for channel: Channel) {
        loadingIndicator.startAnimating()
        
        let chatVC = ChatViewController()
        chatVC.setup(with: channel) { [unowned self] (didSucceed: Bool) in
            guard didSucceed == true else {
                AlertManager.showError("errorFatal".localized, controller: self)
                self.loadingIndicator.stopAnimating()
                return
            }
            
            self.loadingIndicator.stopAnimating()
            
            chatVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    func reloadChannels() {
        DispatchQueue.main.async { [unowned self] in
            // Unsubscribe from all existing channels
            self.removeSubscriptions()
            
            // Retrieve open channels
            HostConnectionManager.shared.getOpenChannelsInActiveHosts { (channels: [Channel]) in
                self.channels = channels
                
                // Handle potential existing push requests
                self.handlePushRequest()
                
                // Resubscribe to all channels
                self.refreshSubsriptions()
            }
        }
    }
    
    private func showEmptyState(_ shouldShow: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if shouldShow {
                UIView.animate(withDuration: 0.2, animations: {
                    self.emptyStateLabel.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.emptyStateLabel.alpha = 0
                })
            }
        }
    }
    
    private func handlePushRequest() {
        guard let request = pushRequest else {
            return
        }
        
        // Open chat for push request
        let foundChannels = channels.filter { $0.roomId == request.roomId }
        guard let foundChannel = foundChannels.first else {
            assert(false, "Could not find channel!")
            return
        }
        openChatView(for: foundChannel)
        pushRequest = nil
    }
    
}


// MARK: - UITableViewDataSource
extension ConversationListViewController: UITableViewDataSource {
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
        
        guard let host = HostConnectionManager.shared.cachedActiveHost(for: channel) else {
            return UITableViewCell()
        }
        
        var lastMessageText: String? = ""
        if let lastMessage = channel.lastMessage() {
            cell.lastMessageDateLabel.text = lastMessage.updated?.timeDifference()
            
            switch lastMessage.dataType() {
            case .googlePlaces:
               lastMessageText = lastMessage.googlePlaces[0].name
            case .attachment, .image:
                if lastMessage.username == host.credentials?.liveChatUsername {
                    lastMessageText = "sentFile".localized
                } else {
                    lastMessageText = "receivedFile".localized
                }
            case .closeChannelMessage:
                lastMessageText = "channel_closed_text".localized
            case.permission:
                lastMessageText = "travelFolderRequestTitle".localized
            case .link:
                lastMessageText = lastMessage.linkHost
            case .location:
                lastMessageText = "localizationShared".localized
            case .message:
                lastMessageText = lastMessage.messageText
            case .permissionAnswer:
                if lastMessage.permissionAnswerGranted {
                    lastMessageText = "travelFolderAccessGranted".localized
                } else {
                    lastMessageText = "travelFolderAccessDenied".localized
                }
                
            case .timeDivisor: break
            case .undefined:break
            }
        }
        
        cell.lastMessageLabel.text = lastMessageText
        cell.avatarLabel.text = host.name.substring(to: 2).uppercased()
        cell.nameLabel.text = host.name
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ConversationListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let channel = channels.get(index: indexPath.row) {
            openChatView(for: channel)
        } else {
            self.reloadChannels()
        }
    }
}


// MARK: - SubscribedConversationDelegate
extension ConversationListViewController: SubscribedConversationDelegate {
    
    func onUpdate(message: ChatMessage, response: SocketResponseMessage) {
        reloadTableView()
    }
    
    func delegateIdentifier() -> String {
        return self.uniqueSubsriptionIdentifier
    }
}
