//
//  SelectHostViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 31.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

typealias SelectHostCompletion = (Host) -> Void

class SelectHostViewController: MasaiBaseViewController {
    
    // MARK: UI
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    // MARK: Properties
    
    var selectCompletionBlock: SelectHostCompletion?
    var hosts: [Host] = []
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellForTableView()
        loadingIndicator.color = UIColor.orangeMasai
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Retrieve hosts from backend
        showLoadingAnimation(true)
        HostConnectionManager.shared.getActiveHosts { [unowned self] (hosts: [Host]) -> (Void) in
            self.showLoadingAnimation(false)
            self.hosts = hosts
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: Private
    
    private func registerCellForTableView() {
        self.tableView.register(UINib(nibName: HostTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: HostTableViewCell.identifier)
    }
    
    private func showLoadingAnimation(_ shouldShow: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if shouldShow {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}


// MARK: MasaiBaseViewController
extension SelectHostViewController {
    override func isNavigationBarVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBar() -> String? {
        return "selectHostViewControllerTitle".localized
    }
    
    override func isNavigationBarRightItemVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBarRightItem() -> String? {
        return "close".localized
    }
    
    override func onPressedNavigationBarRightButton() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: UITableViewDataSource
extension SelectHostViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HostTableViewCell.defaultHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: HostTableViewCell.identifier) as! HostTableViewCell
        let host = self.hosts[indexPath.row]
        cell.avatarLabel.text = host.name.substring(to: 2).uppercased()
        cell.titleLabel.text = host.name
        
        return cell
    }
}


// MARK: UITableViewDelegate
extension SelectHostViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [unowned self] in
            self.selectCompletionBlock?(self.hosts[indexPath.row])
        }
    }
}
