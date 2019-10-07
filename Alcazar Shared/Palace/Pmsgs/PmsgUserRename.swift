//
//  PmsgUserRename.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/6/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserRename: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    public var UserId: UInt32? {
        get {
            return self.Ref!
        }
        set {
            self.Ref = newValue
        }
    }
    
    public var ToUsernameLen: UInt8?
    public var ToUsername: String?
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        self.ToUsernameLen = p.load(as: UInt8.self)
        p += MemoryLayout<UInt8>.stride
        
        let data = Data(bytes: p, count: Int(self.ToUsernameLen!))
        self.ToUsername = String(bytes: data, encoding: .utf8)
        if self.ToUsername == nil {
            self.ToUsername = String(bytes: data, encoding: .windowsCP1252)
        }
        
        super.init(pmsg: pmsg)
    }
    
    init(TargetEndianness: EndianType, ToUsername: String)
    {
        let len = ToUsername.lengthOfBytes(using: .utf8)
        //if len == nil {
        //    len = ToUsername.lengthOfBytes(using: .windowsCP1252)
        //}
        let ui32Len = UInt32(len)
        
        super.init(TargetEndianness: TargetEndianness,
                   Id: .UserRename,
                   Len: ui32Len + 1,
                   Ref: PmsgUserRename.DefaultRef)
        
        self.ToUsernameLen = UInt8(ui32Len)
        self.ToUsername = ToUsername
    }
}
