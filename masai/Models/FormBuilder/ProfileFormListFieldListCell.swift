//
//  ProfileFormListFieldListCell.swift
//  masai
//
//  Created by Florian Rath on 21.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileFormListFieldListCell: FormListFieldListCell {
    
    override var textFieldType: ValidatableViewType.Type {
        return ProfileNoImageTextField.self
    }
    
}
