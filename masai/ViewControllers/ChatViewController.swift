//
//  ChatViewController.swift
//  masai
//
//  Created by Bartłomiej Burzec on 08.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import SlackTextViewController
import Photos
import UIKit
import MapKit
import ImageSlideshow
import Realm
import RealmSwift
import Kingfisher


class ChatViewController: SLKTextViewController {
    
    enum DisplayType {
        case chat
        case history
    }
    
    var displayType = DisplayType.chat
    
    typealias SetupCompletionClosure = (_ didSuccessfullyComplete: Bool) -> Void
    
    let uniqueSubsriptionIdentifier = String.random(length: 50)
    var chatData: [ChatData] = []
    
    var messages = [ChatMessage]()
    
    var socketManager: SocketManager! {
        willSet {
            if channel != nil && socketManager != nil {
                socketManager.unsubscribe(channel: channel, delegate: self)
            }
        }
        didSet {
            if channel != nil && socketManager != nil {
                socketManager.subscribe(channel: channel, delegate: self)
            }
        }
    }
    var channel: Channel! {
        willSet {
            if channel != nil && socketManager != nil {
                socketManager.unsubscribe(channel: channel, delegate: self)
            }
        }
        didSet {
            if channel != nil && socketManager != nil {
                socketManager.subscribe(channel: channel, delegate: self)
            }
            chatData = channel.messages()
        }
    }
    
    var hostUrl: String!
    
    var host: Host {
        return HostConnectionManager.shared.cachedHost(for: hostUrl)!
    }
    
    var currentUsername: String? {
        return host.credentials?.liveChatUsername
    }
    
    let chatOptionView = ChatOptionBarView.instanceFromNib()
    
    var imageDownloadRequestModifier: AnyModifier? {
        didSet {
            if let modifier = imageDownloadRequestModifier {
                kingfisherOptions = [.requestModifier(modifier)]
            } else {
                kingfisherOptions = []
            }
        }
    }
    var kingfisherOptions: KingfisherOptionsInfo = []
    
    var notificationObservationTokens: [Notification.NotificationToken] = []
    
    var searchTerm: String?
    
    var chatIsClosed = false
    
    
    // MARK: Lifecycle
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())!
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        prepareLayout()
        prepareImageDownloader()
        subscribeToNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = []
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReconnect), name: NSNotification.Name(rawValue: Constants.Notification.reconnect), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLoadHistory), name: NSNotification.Name(rawValue: Constants.Notification.historyLoadedNotificationString), object: nil)
        
        chatOptionView.frame.size.width = 0

        socketManager.subscribe(channel: channel, delegate: self)
        
        let closeMessages = chatData.filter { $0.dataType() == .closeChannelMessage }
        if closeMessages.count > 0 {
            closeChatIfNecessary()
        }
        
        reloadConversation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AwsBackendManager.postNewTransactionId { (didSucceed) in
            if !didSucceed {
                AppDelegate.logout(withMessage: "service_not_available".localized)
            }
        }
        
        if let term = searchTerm {
            let foundSearchItems = chatData.filter { $0.dataType() == .message }.filter { ($0 as! ChatMessage).message.lowercased().contains(term.lowercased()) }
            if let firstSearchItem = foundSearchItems.last as? ChatMessage,
                let foundIndex = chatData.index(where: { (chatData) -> Bool in
                    return (chatData as! ChatMessage).id == firstSearchItem.id && (chatData as! ChatMessage).message == firstSearchItem.message
                }) {
                let indexPath = IndexPath(row: foundIndex, section: 0)
                collectionView?.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.reconnect), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.Notification.historyLoadedNotificationString), object: nil)
        
        for token in notificationObservationTokens {
            NotificationCenter.default.removeObserver(token)
        }
        notificationObservationTokens.removeAll()
        
        socketManager.unsubscribe(channel: channel, delegate: self)
    }
    
    
    // MARK: Other
    
    func closeChatIfNecessary() {
        if !chatIsClosed {
            textInputbar.textView.resignFirstResponder()
            disableTextInput()
            
            chatIsClosed = true
        }
    }
    
    func setup(with channel: Channel, completion: @escaping SetupCompletionClosure) {
        HostConnectionManager.shared.socketManager(for: channel, completion: { (sm: SocketManager?) in
            self.channel = channel
            
            if channel.isClosed {
                self.closeChatIfNecessary()
            }
            
            let host = HostConnectionManager.shared.cachedActiveHost(for: channel)!
            self.hostUrl = host.url
            
            if let socketManager = sm {
                self.socketManager = socketManager
                
                socketManager.loadHistory(for: channel)
                
                completion(true)
                return
            }
            
            // We haven't got a socket manager to the host, so we need to connect to it
            HostConnectionManager.shared.connectTo(host: self.host)
                .then { (sm: SocketManager) -> Void in
                    self.socketManager = sm
                    
                    self.channel = channel
                    
                    self.hostUrl = self.host.url
                    
                    sm.loadHistory(for: channel)
                    
                    completion(true)
                }.catch { (error: Error) -> Void in
                    completion(false)
            }
        })
    }
    
    private func prepareImageDownloader() {
        guard let credentials = host.credentials,
            let userIdentifier = credentials.liveChatUserId,
            let userLoginToken = credentials.liveChatUserLoginToken else {
            return
        }
        
        let cookie = "rc_uid=\(userIdentifier);rc_token=\(userLoginToken)"
        
        imageDownloadRequestModifier = AnyModifier { request in
            var r = request
            r.setValue(cookie, forHTTPHeaderField: "Cookie")
            return r
        }
    }
    
    func reloadConversation() {
        chatData = []
        for msg in channel.messages() {
            chatData.append(msg)
        }
        reloadChat()
    }
    
    internal func reloadLastMessage() {
        //FIXME: should implement transition
        reloadChat()
    }
    
    internal func reloadChat() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        if checkTravelfolderAccessRequests() {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func checkTravelfolderAccessRequests() -> Bool {
        let permissionRequests = chatData.filter { $0.dataType() == .permission }
        let openPermissionRequests = permissionRequests.filter { ($0 as? ChatMessage)?.permissionConfirmed == false }
        
        for data in openPermissionRequests {
            guard let message = data as? ChatMessage,
                let address = message.permissionLink,
                let body = message.permissionPayload else {
                    continue
            }
            
            // Define our save closure
            let saveHandledPermissionClosure = {
                Realm.execute({ (realm) in
                    (data as! ChatMessage).permissionConfirmed = true
                })
            }
            
            // If we're in history mode, we won't handle any (potentially) open travel folder requests, but instead set that we already handled them
            if displayType == .history {
                saveHandledPermissionClosure()
                continue
            }
            
            textView.resignFirstResponder()
            
            if let userProfile = CacheManager.retrieveUserProfile(),
                userProfile.hasRequiredFields() {
                // User has filled out the mandatory profile fields, so we'll ask for access to his profile
                
                AlertManager.askAboutPermission(self
                    , onAccess: { [unowned self] (action) in
                        saveHandledPermissionClosure()
                        RestManager.giveTravelFolderPermission(address, body: body, completion: { (success) in
                            self.sendMessageWithTravelFolderPermission(success)
                        })
                    }, onDenied: { [unowned self] (action) in
                        saveHandledPermissionClosure()
                        self.sendMessageWithTravelFolderPermission(false)
                })
            } else {
                // User has not yet filled out mandatory profile fields, so we'll ask him to do so
                AlertManager.askToFillOutMandatoryProfileFields(self, yesClosure: { [unowned self] (_) in
                    guard let tabBarC = self.tabBarController as? MainTabBarController else {
                        return
                    }
                    tabBarC.openProfile()
                    self.navigationController?.popViewController(animated: false)
                    }, noClosure: { [unowned self] (_) in
                        // Since user has declined to fill out mandatory profile fields, we'll cancel the request
                        saveHandledPermissionClosure()
                        self.sendMessageWithTravelFolderPermission(false)
                })
            }
            
            return true
        }
        return false
    }
    
    private func sendMessageWithTravelFolderPermission(_ permission: Bool) {
        guard let message = channel.textMessageForTravelFolderAccess(permission) else {
            return
        }
        
        socketManager.sendTextMessage(in: channel, message: message, completion: { [unowned self] (message: ChatMessage?, updatedChannel: Channel, _: Host?) in
            self.channel = updatedChannel
            
            if let newMessage = message {
                Realm.execute({ (realm) in
                    newMessage.isPermission = true
                    newMessage.permissionAnswerGranted = permission
                })
                self.insertNewMessage(newMessage)
            }
        })
    }
    
    private func prepareLayout() {
        setTextInputbarHidden(false, animated: false)
        view.backgroundColor = UIColor.white
        title = host.name
        textView.placeholder = "chat_input_placeholder".localized
        
        chatOptionView.frame.size.width = 0
        chatOptionView.frame.size.height = self.textInputbar.frame.size.height
        chatOptionView.layer.cornerRadius = self.textInputbar.layer.cornerRadius
        chatOptionView.delegate = self
        
        textInputbar.addSubview(self.chatOptionView)
        
        textInputbar.leftButton.setImage(#imageLiteral(resourceName: "chatbar_add").withRenderingMode(.alwaysOriginal), for: .normal)
        textInputbar.rightButton.setImage(#imageLiteral(resourceName: "chatbar_send").withRenderingMode(.alwaysOriginal), for: .normal)
        let disabledImage = #imageLiteral(resourceName: "chatbar_send").withRenderingMode(.alwaysTemplate)
        textInputbar.rightButton.setImage(disabledImage, for: .disabled)
        textInputbar.rightButton.tintColor = #colorLiteral(red: 0.638127625, green: 0.638127625, blue: 0.638127625, alpha: 1)
        textInputbar.rightButton.setTitle(nil, for: .normal)
        textInputbar.autoHideRightButton = false
    }
    
    private func registerCells() {
        collectionView?.register(UINib(nibName: OwnChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OwnChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: OtherChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OtherChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: ImageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: GooglePlacesCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: GooglePlacesCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: LocationChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: LocationChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: OwnLinkChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OwnLinkChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: OtherLinkChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OtherLinkChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: OwnAttachmentsChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OwnAttachmentsChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: OtherAttachmentsChatMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OtherAttachmentsChatMessageCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: TravelfolderPermissionCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TravelfolderPermissionCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: TravelfolderPermissionAnswerCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: TravelfolderPermissionAnswerCollectionViewCell.identifier)
        collectionView?.register(UINib(nibName: CloseChannelMessageCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CloseChannelMessageCollectionViewCell.identifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatData.count
    }
    
    // fixme: method need refactor
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataForCell = self.chatData[indexPath.row]
        switch dataForCell.dataType() {
        case .message:
            if let data = dataForCell as? ChatMessage, let username = self.currentUsername, let messageUser = data.username {
                if username == messageUser {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OwnChatMessageCollectionViewCell.identifier, for: indexPath) as! OwnChatMessageCollectionViewCell
                    cell.messageTextView.text = data.message
                    if let term = searchTerm,
                        data.message.lowercased().contains(term.lowercased()) {
                        cell.setAsMarked(true)
                    } else {
                        cell.setAsMarked(false)
                    }
                    cell.dateLabel.text = data.date?.shortString()
                    
                    var statusImage: UIImage?
                    switch data.status {
                    case .sent:
                        statusImage = UIImage(named: Constants.Images.messageStatusSent)
                    case .sending:
                        statusImage = UIImage(named: Constants.Images.messageStatusSending)
                    case .failed:
                        statusImage = UIImage(named: Constants.Images.messageStatusFailed)
                    }
                    
                    cell.messageStatusImageView.image = statusImage
                    cell.transform = collectionView.transform
                    cell.layoutIfNeeded()
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherChatMessageCollectionViewCell.identifier, for: indexPath) as! OtherChatMessageCollectionViewCell
                    
                    cell.loadAvatar(rcBaseUrl: hostUrl, username: data.username!)
                    if self.chatData.count > indexPath.row + 1 {
                        let previousCellData = self.chatData[indexPath.row + 1]
                        if let prevData = previousCellData as? ChatMessage, let prevMessageUser = prevData.username, prevMessageUser == messageUser {
                            cell.hideAvatarView()
                        }
                    }
                    
                    cell.messageTextView.text = data.message
                    if let term = searchTerm,
                        data.message.lowercased().contains(term.lowercased()) {
                        cell.setAsMarked(true)
                    }
                    
                    cell.dateLabel.text = data.date?.shortString()
                    cell.transform = collectionView.transform
                    cell.layoutIfNeeded()
                    return cell
                }
            }
            
        case .closeChannelMessage:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CloseChannelMessageCollectionViewCell.identifier, for: indexPath) as! CloseChannelMessageCollectionViewCell
            cell.transform = collectionView.transform
            cell.layoutIfNeeded()
            
            closeChatIfNecessary()
            
            return cell
            
        case .timeDivisor: break
            
        case .undefined: break
            
        case .image:
            if let data = dataForCell as? ChatMessage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
                
                if data.username == self.currentUsername {
                    cell.type = .own
                } else {
                    cell.type = .other
                }
                
                cell.dateLabel.text = data.date?.shortString()
                cell.loadAvatar(rcBaseUrl: hostUrl, username: data.username!)
                
                var statusImage: UIImage?
                switch data.status {
                case .sent:
                    statusImage = UIImage(named: Constants.Images.messageStatusSent)
                case .sending:
                    statusImage = UIImage(named: Constants.Images.messageStatusSending)
                case .failed:
                    statusImage = UIImage(named: Constants.Images.messageStatusFailed)
                }
                
                cell.messageStatusImgeView.image = statusImage
                cell.delegate = self
                cell.transform = collectionView.transform
                
                if data.imageStoredLocally, let imageName = data.imageName {
                    let image = CacheManager.cachedImage(imageName)
                    cell.photoImageView.image = image
                } else if let imageLink  = data.imageLink,
                    let url = URL(string: host.restEndpoint(imageLink)) {
                    cell.photoImageView.kf.setImage(with: url, placeholder: nil, options: kingfisherOptions)
                }
                
                return cell
            }
            
        case .googlePlaces:
            if let message = self.chatData[indexPath.row] as? ChatMessage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GooglePlacesCollectionViewCell.identifier, for: indexPath) as! GooglePlacesCollectionViewCell
                
                cell.places = message.googlePlaces
                cell.delegateForCell = self
                cell.reloadData()
                cell.transform = collectionView.transform
                return cell
            }
        case .location:
            if let message = self.chatData[indexPath.row] as? ChatMessage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationChatMessageCollectionViewCell.identifier, for: indexPath) as! LocationChatMessageCollectionViewCell
                
                cell.setLocation(lat: message.latitude, long: message.longitude)
                cell.locationNameLabel.text = message.locationName
                cell.dateLabel.text = message.date?.shortString()
                
                var statusImage: UIImage?
                switch message.status {
                case .sent:
                    statusImage = UIImage(named: Constants.Images.messageStatusSent)
                case .sending:
                    statusImage = UIImage(named: Constants.Images.messageStatusSending)
                case .failed:
                    statusImage = UIImage(named: Constants.Images.messageStatusFailed)
                }
                
                cell.messageStatusImageView.image = statusImage
                cell.delegate = self
                cell.transform = collectionView.transform
                
                return cell
            }
            
        case .link:
            if let message = self.chatData[indexPath.row] as? ChatMessage, let user = self.currentUsername, let messageUser = message.username {
                if user == messageUser {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OwnLinkChatMessageCollectionViewCell.identifier, for: indexPath) as! OwnLinkChatMessageCollectionViewCell
                    
                    cell.delegate = self
                    cell.linkUrl = message.linkUrl
                    
                    if message.messageWithoutUrls.isEmpty {
                        cell.messageTextViewVisible(false)
                    } else {
                        cell.messageTextViewVisible(true)
                    }
                    
                    cell.messageTextView.text = message.messageWithoutUrls
                                        
                    cell.linkTitleLabel.text = message.linkTitle
                    cell.linkDescriptionLabel.text = message.linkDescription
                    cell.linkHostLabel.text = message.linkHost
                    cell.dateLabel.text = message.date?.shortString()
                    if let imageUrl = message.linkImageUrl {
                        let url = URL(string: imageUrl)
                        cell.linkImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "no_image_placeholder"), options: kingfisherOptions)
                    } else {
                        cell.linkImageView.image = #imageLiteral(resourceName: "no_image_placeholder")
                    }
                    
                    var statusImage: UIImage?
                    switch message.status {
                    case .sent:
                        statusImage = UIImage(named: Constants.Images.messageStatusSent)
                    case .sending:
                        statusImage = UIImage(named: Constants.Images.messageStatusSending)
                    case .failed:
                        statusImage = UIImage(named: Constants.Images.messageStatusFailed)
                    }
                    cell.messageStatusImageView.image = statusImage
                    
                    cell.layoutIfNeeded()
                    cell.transform = collectionView.transform
                    return cell
                    
                } else {
                    let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: OtherLinkChatMessageCollectionViewCell.identifier, for: indexPath) as! OtherLinkChatMessageCollectionViewCell
                    
                    cell.delegate = self
                    cell.linkUrl = message.linkUrl
                    
                    if message.messageWithoutUrls.isEmpty {
                        cell.messageTextViewVisible(false)
                    } else {
                        cell.messageTextViewVisible(true)
                    }
                    
                    cell.messageTextView.text = message.messageWithoutUrls
                    cell.linkTitleLabel.text = message.linkTitle
                    cell.linkDescriptionLabel.text = message.linkDescription
                    cell.linkHostLabel.text = message.linkHost
                    cell.dateLabel.text = message.date?.shortString()
                    
                    if let imageUrl = message.linkImageUrl {
                        let url = URL(string: imageUrl)
                        cell.linkImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "no_image_placeholder"), options: kingfisherOptions)
                    } else {
                        cell.linkImageView.image = #imageLiteral(resourceName: "no_image_placeholder")
                    }
                    
                    cell.loadAvatar(rcBaseUrl: hostUrl, username: messageUser)
                    if self.chatData.count > indexPath.row + 1 {
                        let previousCellData = self.chatData[indexPath.row + 1]
                        if let prevData = previousCellData as? ChatMessage, let prevMessageUser = prevData.username, prevMessageUser == messageUser {
                            cell.hideAvatarView()
                        }
                    }
                    
                    cell.layoutIfNeeded()
                    cell.transform = collectionView.transform
                    return cell
                }
            }
        case .attachment:
            if let message = self.chatData[indexPath.row] as? ChatMessage, let user = self.currentUsername, let messageUser = message.username {
                if user == messageUser {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OwnAttachmentsChatMessageCollectionViewCell.identifier, for: indexPath) as! OwnAttachmentsChatMessageCollectionViewCell
                    
                    cell.descriptionLabel.text = message.attachmentText
                    cell.dateLabel.text = message.date?.shortString()
                    cell.attachmentLink = message.attachmentLink
                    
                    cell.delegate = self
                    
                    cell.transform = collectionView.transform
                    cell.layoutIfNeeded()
                    
                    return cell
                    
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherAttachmentsChatMessageCollectionViewCell.identifier, for: indexPath) as! OtherAttachmentsChatMessageCollectionViewCell
                    
                    cell.descriptionLabel.text = message.attachmentText
                    cell.dateLabel.text = message.date?.shortString()
                    cell.attachmentLink = message.attachmentLink
                    
                    cell.loadAvatar(rcBaseUrl: hostUrl, username: messageUser)
                    
                    cell.delegate = self
                    
                    cell.transform = collectionView.transform
                    cell.layoutIfNeeded()
                    
                    return cell
                }
                
            }
        case .permission:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelfolderPermissionCollectionViewCell.identifier, for: indexPath) as! TravelfolderPermissionCollectionViewCell
            cell.transform = collectionView.transform
            return cell
            
        case .permissionAnswer:
            if let message = self.chatData[indexPath.row] as? ChatMessage {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TravelfolderPermissionAnswerCollectionViewCell.identifier, for: indexPath) as! TravelfolderPermissionAnswerCollectionViewCell
                
                if message.permissionAnswerGranted {
                    cell.access()
                } else {
                    cell.denied()
                }
                
                cell.transform = collectionView.transform
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func insertNewMessage(_ message: ChatMessage) {
        for data in self.chatData {
            if let msg = data as? ChatMessage, msg.identifier == message.identifier {
                reloadChat()
                return
            }
        }
        
        self.chatData.insert(message, at: 0)
        reloadLastMessage()
    }
    
    func isOptionBarEnabled(_ enable: Bool) {
        var width: CGFloat = 0.0
        if enable {
            width = self.textInputbar.frame.size.width
            self.textView.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.25) {
            self.chatOptionView.frame.size.width = width
        }
    }
    
    func sendLocationMessage(lat: Double, long: Double, name: String?) {
        guard let roomId = channel.roomId else {
                assert(false, "Could not get channel name and room id")
                return
        }
        
        socketManager.sendLocalization(roomId: roomId, lat: lat, long: long, name: channel.name, completion: { [unowned self] (_: SocketResponseMessage?, message: ChatMessage?) in
            if let newMessage = message {
                self.insertNewMessage(newMessage)
            }
        })
    }
    
    override func didPressRightButton(_ sender: Any?) {
        sendTextInTextfield()
        
        super.didPressRightButton(sender)
    }
    
    override func didPressLeftButton(_ sender: Any?) {
        isOptionBarEnabled(true)
    }
    
    func openNavigation(for place:GooglePlace) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(place.lat, place.long)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = place.name
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func goToSearch(_ place: GooglePlace) {
        if let name = place.name {
            AppDelegate.openSearch(name)
        }
    }
    
    func onLoadHistory() {
        reloadConversation()
    }
    
    func onReconnect() {
        reloadConversation()
    }
    
    func openPhotoLiblaryForUpload() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = mediaTypes
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func openCameraForUpload() {
        let imagePicker  = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        imagePicker.cameraFlashMode = .off
        imagePicker.cameraCaptureMode = .photo
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func openLocationPicker() {
        let locationPickerVC = SelectLocationViewController()
        locationPickerVC.completion = { (location) in
            if let lat = location?.latitude, let long = location?.longitude {
                RestManager.getLocationDetails(lat: lat, long: long, completion: { (json, success) in
                    if let json = json {
                        let name = json[Constants.Network.Json.results][0][Constants.Network.Json.formattedAddress].string
                        DispatchQueue.main.async {
                            self.sendLocationMessage(lat: lat, long: long, name: name)
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.sendLocationMessage(lat: lat, long: long, name: "")
                        }
                    }
                })
            }
        }
        locationPickerVC.modalPresentationStyle = .overCurrentContext
        present(locationPickerVC, animated: true, completion: nil)
    }
    
    func openMaps(_ location: CLLocationCoordinate2D) {
        let regionDistance:CLLocationDistance = 10000
        let regionSpan = MKCoordinateRegionMakeWithDistance(location, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: options)
    }
    
    func subscribeToNotifications() {
        let closeChannelToken = Constants.Notification.closeChannel.observe { [unowned self] (receivedNotification: Notification) in
            guard let userInfo = receivedNotification.userInfo,
                let channel = userInfo["channel"] as? Channel,
                let message = userInfo["message"] as? ChatMessage,
                channel.roomId == self.channel.roomId else {
                    return
            }
            
            // Show chat closed message
            self.insertNewMessage(message)
            self.reloadChat()
            
            // Disable input
            self.closeChatIfNecessary()
        }
        notificationObservationTokens.append(closeChannelToken)
        
        let historyToken = Constants.Notification.historyLoaded.observe(eventClosure: { (note: Notification) in
            guard let userInfo = note.userInfo,
                let channel = userInfo["channel"] as? Channel,
                channel.roomId == self.channel.roomId else {
                    return
            }
            self.reloadConversation()
        })
        notificationObservationTokens.append(historyToken)
    }
    
    func disableTextInput() {
        DispatchQueue.main.async { [unowned self] in
            self.setTextInputbarHidden(true, animated: true)
            self.reloadChat()
        }
    }
    
    func sendTextInTextfield() {
        socketManager.sendTextMessage(in: channel, message: textView.text, completion: { [unowned self] (message: ChatMessage?, updatedChannel: Channel, _: Host?) in
            self.channel = updatedChannel
            
            if let m = message {
                self.insertNewMessage(m)
            }
        })
    }
    
    
    // MARK: Statusbar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension ChatViewController: ImageCollectionViewCellDelegate {
    
    func onImageViewPressed(_ imageView: UIImageView) {
        if let image = imageView.image {
            let fullScreenController = MasaiPhotoFullscreenViewController()
            fullScreenController.images = [image]
            fullScreenController.slideshow.pageControlPosition = .hidden
            fullScreenController.modalTransitionStyle = .crossDissolve
            
            self.present(fullScreenController, animated: true, completion: nil)
        }
    }
}


// MARK: UICollectionViewDelegateFlowLayout
extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = UIScreen.main.bounds.size.width
        var height: CGFloat = 0
        
        let dataForCell = self.chatData[indexPath.row]
        switch dataForCell.dataType() {
        case .message:
            let data = dataForCell as! ChatMessage
            if currentUsername == data.username {
                height = OwnChatMessageCollectionViewCell.calculateHeight(for: data)
            } else {
                height = OtherChatMessageCollectionViewCell.calculateHeight(for: data)
            }
            
        case .closeChannelMessage:
            height = CloseChannelMessageCollectionViewCell.calculateHeight(for: dataForCell as! ChatMessage)
            
        case .image:
            height = ImageCollectionViewCell.calculateHeight()
            
        case .googlePlaces:
            height = GooglePlacesCollectionViewCell.calculateHeight()
            
        case .location:
            height = LocationChatMessageCollectionViewCell.calculateHeight()
        case .link:
            if let data = dataForCell as? ChatMessage {
                height = OtherLinkChatMessageCollectionViewCell.calculateHeight(for: data)
            }
        case .attachment:
            if let data = dataForCell as? ChatMessage {
                if currentUsername == data.username {
                    height = OwnAttachmentsChatMessageCollectionViewCell.calculateHeight(for: data)
                } else {
                    height = OtherAttachmentsChatMessageCollectionViewCell.calculateHeight(for: data)
                }
            }
        case .permission:
            height = TravelfolderPermissionCollectionViewCell.calculateHeight()
        case .permissionAnswer:
            height = TravelfolderPermissionAnswerCollectionViewCell.calculateHeight()
            
        case .timeDivisor: break
        case .undefined: break
        }
        
        return CGSize(width: fullWidth, height: height)
    }
}

extension ChatViewController: SubscribedConversationDelegate {
    
    func onUpdate(message: ChatMessage, response: SocketResponseMessage) {
        insertNewMessage(message)
    }
    
    func delegateIdentifier() -> String {
        return self.uniqueSubsriptionIdentifier
    }
}

extension ChatViewController: UINavigationControllerDelegate {
    
}


// MARK: UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var filename = "\(String.random()).jpeg"
        
        if let assetURL = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject,
            let resource = PHAssetResource.assetResources(for: asset).first {
            filename = resource.originalFilename
        }
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizedImage = image.resize(width: 1024) ?? image
            guard let imageData = UIImageJPEGRepresentation(resizedImage, 0.9) else { return }
            
            let file = FileForUpload(
                name: filename,
                size: (imageData as NSData).length,
                type: "image/jpeg",
                data: imageData
            )
            
            UploadManager.sharedInstance.upload(file: file, channel: channel, messageReceiver: { (newMessage) in
                DispatchQueue.main.async {
                    self.insertNewMessage(newMessage)
                }
            }, completion: { (response, success) in
                if success {
                    AlertManager.showInfo("chat_fileupload_success".localized, controller: self)
                } else {
                    AlertManager.showError("chat_fileupload_error".localized, controller: self)
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChatViewController: GooglePlaceDelegate {
    
    func onPressedMap(_ place: GooglePlace) {
        openNavigation(for: place)
    }
    
    func onPressedSearch(_ place: GooglePlace) {
        goToSearch(place)
    }
}

extension ChatViewController: LocationMessageDelegate {
    func onMapPressed(_ location: CLLocationCoordinate2D) {
        openMaps(location)
    }
}


extension ChatViewController: ChatOptionBarDelegate {
    
    func onCamButtonPressed() {
        openCameraForUpload()
    }
    
    func onLocationButtonPressed() {
        openLocationPicker()
    }
    
    func onFileButtonPressed() {
        AlertManager.showInfo("comingSoon".localized, controller: self, handler: nil)
    }
    
    func onGalleryButtonPressed() {
        openPhotoLiblaryForUpload()
    }
    
    func onKeyboardButtonPressed() {
        isOptionBarEnabled(false)
    }
    
}

extension ChatViewController: AttachmentsMessageDelegate {
    
    func onAttachmentsButtonPressed(_ link: String) {
        let webView = MasaiWebViewController()
        let link = host.restEndpoint(link)
        webView.requestAddress = link
        webView.credentials = host.credentials
        let navController = BaseNavigationController(rootViewController: webView)
        self.present(navController, animated: true, completion: nil)
    }
    
}

extension ChatViewController: LinkMessageDelegate {
    func onLinkButtonPressed(url: String) {
        AppDelegate.openWebsite(url)
    }
    
}

