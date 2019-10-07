//
//  Pmessage.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/17/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation


public enum PmessageType: Int
{
    case Trace = 0x01
    case Debug = 0x02
    case Error = 0x04
    case Warning = 0x08
    case Info = 0x10
    case System = 0x20
    case Whisper = 0x40
    case Say = 0x80
    case Whitespace = 0x8000
    /*
     public static func ==(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs == rhs
     }
     
     public static func !=(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs != rhs
     }
     
     public static func <(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs < rhs
     }
     
     public static func <=(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs <= rhs
     }
     
     public static func >(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs > rhs
     }
     
     public static func >=(lhs: PlogMessageType, rhs: PlogMessageType) -> Bool
     {
     return lhs >= rhs
     } */
}

public class Pmessage
{
    var user: Puser?
    var content: String
    var type: PmessageType
    
    init(user: Puser?, content: String, type: PmessageType)
    {
        self.user = user
        self.content = content
        self.type = type
    }
}
