//
//  TraitOptions.swift
//  calendar
//
//  Created by Florian Rath on 07.06.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit

struct TraitOptions {
    
    var horizontalSizeClass: UIUserInterfaceSizeClass?
    var verticalSizeClass: UIUserInterfaceSizeClass?
    var idiom: UIUserInterfaceIdiom?
    
    init(horizontalSizeClass: UIUserInterfaceSizeClass? = nil, verticalSizeClass: UIUserInterfaceSizeClass? = nil, idiom: UIUserInterfaceIdiom? = nil) {
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.idiom = idiom
    }
    
    static var always: TraitOptions {
        return TraitOptions()
    }
    
    static func from(traits: UITraitCollection) -> TraitOptions {
        let options = TraitOptions(horizontalSizeClass: traits.horizontalSizeClass,
                                   verticalSizeClass: traits.verticalSizeClass,
                                   idiom: traits.userInterfaceIdiom)
        return options
    }
    
    func matches(options: TraitOptions) -> Bool {
        var matches = true
        
        if let selfValue = horizontalSizeClass,
            let otherValue = options.horizontalSizeClass,
            selfValue != otherValue {
            matches = false
        }
        
        if let selfValue = verticalSizeClass,
            let otherValue = options.verticalSizeClass,
            selfValue != otherValue {
            matches = false
        }
        
        if let selfValue = idiom,
            let otherValue = options.idiom,
            selfValue != otherValue {
            matches = false
        }
        
        return matches
    }
    
}

extension TraitOptions: Equatable {
    
    public static func == (lhs: TraitOptions, rhs: TraitOptions) -> Bool {
        return lhs.horizontalSizeClass == rhs.horizontalSizeClass &&
            lhs.verticalSizeClass == rhs.verticalSizeClass &&
            lhs.idiom == rhs.idiom
    }
    
}

extension TraitOptions: Hashable {
    
    var hashValue: Int {
        let horizontalString = String(describing: horizontalSizeClass?.rawValue)
        let verticalString = String(describing: verticalSizeClass?.rawValue)
        let idiomString = String(describing: idiom?.rawValue)
        return "\(horizontalString);\(verticalString);\(idiomString)".hashValue
    }
    
}
