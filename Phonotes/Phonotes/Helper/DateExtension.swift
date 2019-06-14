//
//  DateExtension.swift
//  Phonotes
//
//  Created by Leah Xia on 2019-06-12.
//  Copyright © 2019 Leah Xia. All rights reserved.
//

import Foundation

extension Date {
    func dateFormatterOfMonthDayYear() -> String  {
        return generalDateFormatter(format: "MMMM d, yyyy")
    }
    
    func generalDateFormatter(format: String) -> String  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
