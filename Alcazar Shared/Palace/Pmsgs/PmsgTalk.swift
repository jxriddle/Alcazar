//
//  PmsgSay.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/15/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgTalk: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    public var Message: String?
    public var FromUserId: UInt32? {
        get {
            return self.Ref!
        }
        
        set {
            self.Ref = newValue
        }
    }
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        let messageData = Data(bytes: p, count: Int(pmsg.Len!))
        self.Message = String(bytes: messageData, encoding: .utf8)
        if self.Message == nil {
            self.Message = String(bytes: messageData, encoding: .windowsCP1252)
        }
        
        super.init(pmsg: pmsg)
    }
    
    init(TargetEndianness: EndianType, Message: String)
    {
        super.init(TargetEndianness: TargetEndianness, Id: .Talk, Len: UInt32(Message.lengthOfBytes(using: .utf8)), Ref: PmsgTalk.DefaultRef)
        self.Message = Message
    }
}
