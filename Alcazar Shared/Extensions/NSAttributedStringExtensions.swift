//
//  NSAttributedStringExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/10/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

extension NSAttributedString {
    // concatenate attributed strings
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
    /*
    func draw(at: NSPoint, withAttributes: [NSAttribute])
    {
        let shadowOffset = self.shadowOffset
        let color = self.
    } */
}
