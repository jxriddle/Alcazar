//
//  StringExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript(i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
    func unescape() -> String {
        var s = ""
        
        if length <= 0 {
            return s
        }
        
        for i in 1 ..< length {
            if self[i - 1] == "\\" {
                switch (self[i]) {
                    case "r":
                        break;
                    case "n":
                        s.append(" ")
                        break;
                    case "/":
                        s.append("/")
                        break;
                    case "\\":
                        s.append("\\")
                        break;
                    default:
                        s.append("\\" + self[i])
                        break;
                }
            }
            else {
                s.append(self[i - 1])
            }
        }
        
        s.append(self.characters.last!)
        
        return s
    }
}
