//
//  Language.swift
//  masai
//
//  Created by Florian Rath on 30.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


enum Language {
    case en
    case de
}


class LanguageHelper {
    
    static var currentLanguage: Language {
        let pre = Locale.current.languageCode
        
        switch pre {
        case .some("de"):
            return Language.de
        default:
            return Language.en
        }
    }
    
}
