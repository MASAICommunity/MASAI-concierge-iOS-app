//
//  MasaiPhotoFullscreenViewController.swift
//  masai
//
//  Created by Bartomiej Burzec on 30.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import ImageSlideshow

class MasaiPhotoFullscreenViewController: FullScreenSlideshowViewController {

    private let shareButtonHeight = 20.0
    private let shareButtonWidth = 20.0
    private let shareButtonMargins = 16.0
    var images: [UIImage]? {
        didSet {
            self.inputs = images?.map{ ImageSource(image: $0)}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShareButton()
        
        closeButton.setImage(#imageLiteral(resourceName: "ic_message_failed"), for: UIControlState())
        closeButton.backgroundColor = UIColor.lightGray
        closeButton.layer.cornerRadius = 4.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func prepareLayout() {
        self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.95)
    }
    
    private func addShareButton() {
        let button = UIButton.init(frame: CGRect(x:shareButtonMargins , y: Double(UIScreen.main.bounds.height) - shareButtonMargins - shareButtonHeight, width: shareButtonWidth, height: shareButtonHeight))
        button.addTarget(self, action: #selector(onShareButtonPressed), for: .touchUpInside)
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "ic_share"), for: .normal)
        self.view.addSubview(button)
    }
    
    @objc private func onShareButtonPressed() {
        if let image = self.images?.first {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }
    
}
