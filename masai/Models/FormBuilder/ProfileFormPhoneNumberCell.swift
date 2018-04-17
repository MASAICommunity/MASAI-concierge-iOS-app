//
//  ProfileFormPhoneNumberCell.swift
//  masai
//
//  Created by Florian Rath on 17.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit
import PhoneNumberKit


class ProfileFormPhoneNumberCell: FormTextCell {
    
    override var textFieldType: ValidatableViewType.Type {
        return ProfilePhoneNumberTextFieldView.self
    }
    
}

