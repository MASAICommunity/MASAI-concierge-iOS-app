//
//  OtherAvatarBaseCollectionViewCell.swift
//  masai
//
//  Created by Florian Rath on 03.01.18.
//  Copyright © 2018 5lvlup gmbh. All rights reserved.
//

import UIKit
import Kingfisher


class OtherAvatarBaseCollectionViewCell: UICollectionViewCell {
    
    // MARK: UI
    
    @IBOutlet internal weak var avatarView: UIView!
    @IBOutlet internal weak var avatarImage: UIImageView!
    
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.layer.cornerRadius = self.avatarView.bounds.size.width / 2
        avatarView.clipsToBounds = true
    }
    
    
    // MARK: Cell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarView.isHidden = false
        avatarImage.image = nil
    }
    
    
    // MARK: Avatar handling
    
    func hideAvatarView() {
        avatarView.isHidden = true
    }
    
    func loadAvatar(rcBaseUrl: String, username: String) {
        let avatarUrl = URL(string: Constants.Network.RocketChatApi.getAvatarEndpoint(on: rcBaseUrl, for: username))!
        
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(with: avatarUrl, placeholder: nil, options: nil, progressBlock: nil) { [unowned self] (image: Image?, error: NSError?, cacheType: CacheType, url: URL?) in
            guard let im = image else {
                if let generatedImage = self.generateAvatar(text: username) {
                    let cacheKey = avatarUrl.absoluteString
                    ImageCache.default.store(generatedImage, forKey: cacheKey)
                    self.avatarImage.image = generatedImage
                }
                return
            }
            self.avatarImage.image = im
        }
    }
    
    private func generateAvatar(text: String) -> UIImage? {
        let bgView = UIView()
        bgView.bounds = avatarView.bounds
        bgView.backgroundColor = UIColor.orangeMasai
        bgView.layer.cornerRadius = avatarView.layer.cornerRadius
        bgView.clipsToBounds = true
        
        let label = UILabel()
        label.bounds = bgView.bounds
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        label.text = text.substring(to: 2).uppercased()
        label.textAlignment = .center
        label.textColor = UIColor.white
        bgView.addSubview(label)
        
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size, false, 0)
        bgView.layer.render(in: UIGraphicsGetCurrentContext()!)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let avatarImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return avatarImage
    }
    
}
