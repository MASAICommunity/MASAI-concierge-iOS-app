//
//  ProfileFormCell.swift
//  masai
//
//  Created by Florian Rath on 15.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


class ProfileFormTextCell: FormTextCell {
    
    override var textFieldType: ValidatableViewType.Type {
        return ProfileFormTextFieldView.self
    }
    
}
