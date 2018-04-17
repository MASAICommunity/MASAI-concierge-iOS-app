//
//  AboutViewController.swift
//  masai
//
//  Created by Florian Rath on 29.03.18.
//  Copyright © 2018 5lvlup gmbh. All rights reserved.
//

import UIKit
import SafariServices


class AboutViewController: MasaiBaseViewController {

    // MARK: UI
    
    @IBOutlet weak var tableView: UITableView!

    
    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()
        tableView.reloadData()
    }
    
    
    // MARK: MasaiBaseViewController
    
    override func isNavigationBarVisible() -> Bool {
        return true
    }
    
    override func titleForNavigationBar() -> String? {
        return "about".localized
    }

    
    // MARK: Private
    
    private var currentVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    private var currentBuildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    fileprivate func showVersion() {
        let alert = UIAlertController(title: "Info", message: "\("profile_appInfoText".localized) \(currentVersion) (\(currentBuildNumber))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showWebView(for urlString: String) {
        guard let url = URL(string: urlString) else {
            assert(false)
            return
        }
        
        let vc = SFSafariViewController(url: url)
        vc.preferredControlTintColor = .orangeMasai
        present(vc, animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource
extension AboutViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutMenuTableViewCell") as! AboutMenuTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.label.text = "privacy_policy".localized
        case 1:
            cell.label.text = "terms_of_service".localized
        case 2:
            cell.label.text = "version".localized
        default:
            break
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension AboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let urlString = Constants.Network.AwsBackend.Endpoints.privacyPolicy
            showWebView(for: urlString)
            break
        case 1:
            let urlString = Constants.Network.AwsBackend.Endpoints.termsOfService
            showWebView(for: urlString)
            break
        case 2:
            showVersion()
            break
        default:
            break
        }
    }
}
