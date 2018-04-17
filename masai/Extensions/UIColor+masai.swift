//
//  UIColor+masai.swift
//  masai
//
//  Created by Bartomiej Burzec on 27.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit

extension  UIColor {
    
    public class var navigationWhite: UIColor {
        return UIColor.init(white: 1, alpha: 0.8)
    }
    
    public class var accessGreen: UIColor {
        return UIColor(red: 43/255, green: 204/255, blue: 113/255, alpha: 1.0)
    }
    
    public class var deniedRed: UIColor {
        return UIColor(red: 217/255, green: 30/255, blue: 24/255, alpha: 1.0)
    }
    
    public class var orangeMasai : UIColor {
        return UIColor(red: 233/255, green: 91/255, blue: 43/255, alpha: 1.0)
    }
    
    public class var dbRed : UIColor {
        return UIColor(red: 222/255, green: 53/255, blue: 41/255, alpha: 1.0)
    }
    
    public class var greyMasai: UIColor {
        return UIColor(red: 69/255, green: 90/255, blue: 100/255, alpha: 1.0)
    }
    
    public class var semiDarkGreyMasai: UIColor {
        return UIColor(red: 135/255, green: 145/255, blue: 149/255, alpha: 1.0)
    }
    
    public class var chatMessageBlue: UIColor {
        return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    }
    
    public class var chatMessageOrange: UIColor {
        return orangeMasai
    }
    
    public class var chatMessageGreen: UIColor {
        return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    public class var borderGrey: UIColor {
        return UIColor(white: 235.0/255.0, alpha: 1.0)
    }
}
