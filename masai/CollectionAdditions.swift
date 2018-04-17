//
//  CollectionAdditions.swift
//  masai
//
//  Created by Florian Rath on 09.11.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation


extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    func get(index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
