//
//  Colors.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-05-19.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

struct Colors {
    static let backgroundColor = UIColor.rgb(red: 29, green: 29, blue: 29)
    static let primaryColor = UIColor.rgb(red: 255, green: 84, blue: 84)
    static let placeholderColor = UIColor.rgb(red: 139, green: 139, blue: 139)
}
