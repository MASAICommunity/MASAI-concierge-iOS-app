//
//  UILabel+Utils.swift
//  masai
//
//  Created by Bartłomiej Burzec on 08.02.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import Foundation

extension UILabel {
    static func height(with text: String, font: UIFont, width: CGFloat) -> CGFloat {
        return height(with: text, numberOfLines: 0, font: font, width: width)
    }
    
    static func height(with text: String, numberOfLines: Int, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }

    
}
