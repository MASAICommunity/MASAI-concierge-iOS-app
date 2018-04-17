//
//  TraitProxyView.swift
//  calendar
//
//  Created by Florian Rath on 07.06.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

class TraitProxyView: UIView {
    
    typealias TraitCollectionDidChangeClosure = ((_ currentTraitCollection: UITraitCollection, _ previousTraitCollection: UITraitCollection?) -> Void)
    var traitCollectionDidChangeClosure: TraitCollectionDidChangeClosure?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        traitCollectionDidChangeClosure?(traitCollection, previousTraitCollection)
    }
    
}
