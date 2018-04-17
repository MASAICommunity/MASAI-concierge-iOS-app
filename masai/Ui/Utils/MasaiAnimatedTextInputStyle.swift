//
//  MasaiAnimatedTextInputStyle.swift
//  masai
//
//  Created by Bartomiej Burzec on 26.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import AnimatedTextInput

/* This temporary custom style */
//TODO: specyfic correct values of style variables

struct MasaiAnimatedTextInputStyle: AnimatedTextInputStyle {
    let activeColor = UIColor.dbRed
    let inactiveColor = UIColor.semiDarkGreyMasai
    let lineInactiveColor = UIColor.semiDarkGreyMasai
    let errorColor = UIColor.red
    let textInputFont = UIFont.systemFont(ofSize: 15)
    let textInputFontColor = UIColor.black
    let placeholderMinFontSize: CGFloat = 12
    let counterLabelFont: UIFont? = UIFont.systemFont(ofSize: 9)
    let leftMargin: CGFloat = 0
    let topMargin: CGFloat = 20
    let rightMargin: CGFloat = 0
    let bottomMargin: CGFloat = 10
    let yHintPositionOffset: CGFloat = 3
    let yPlaceholderPositionOffset: CGFloat = 0
}
