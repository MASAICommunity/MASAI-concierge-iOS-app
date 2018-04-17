//
//  ChatOptionBarView.swift
//  masai
//
//  Created by Bartomiej Burzec on 22.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

protocol ChatOptionBarDelegate: class {
    func onKeyboardButtonPressed()
    func onCamButtonPressed()
    func onGalleryButtonPressed()
    func onLocationButtonPressed()
    func onFileButtonPressed()
}


public class ChatOptionBarView: UIView {
    
   weak var delegate: ChatOptionBarDelegate?
    
    class func instanceFromNib() -> ChatOptionBarView {
        return UINib(nibName: "ChatOptionBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ChatOptionBarView
    }
    @IBAction func onKeyboardButtonPressed(_ sender: Any) {
        delegate?.onKeyboardButtonPressed()
    }
    
    @IBAction func onCamButtonPressed(_ sender: Any) {
        delegate?.onCamButtonPressed()
    }
    
    @IBAction func onGalleryButtonPressed(_ sender: Any) {
        delegate?.onGalleryButtonPressed()
    }
    
    @IBAction func onLocationButtonPressed(_ sender: Any) {
        delegate?.onLocationButtonPressed()
    }
    
    @IBAction func onFileButtonPressed(_ sender: Any) {
        delegate?.onFileButtonPressed()
    }
    
}
