//
//  ProfileFormSelectionCell.swift
//  masai
//
//  Created by Florian Rath on 16.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileFormSelectionCell: FormSelectionCell {
    
    override var textFieldType: ValidatableViewType.Type {
        return ProfileFormTextFieldView.self
    }
    
}
