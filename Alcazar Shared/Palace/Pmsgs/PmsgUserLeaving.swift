//
//  PmsgUserLeaving.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/24/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserLeaving: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000004
    public static let DefaultRef: UInt32 = 0x00000000
    
    var UserId: UInt32 {
        get {
            if self.Ref != nil {
                return self.Ref!
            }
            else {
                return UInt32(0)
            }
        }
        
        set {
            self.Ref = newValue
        }
    }
    
    var UsersRemaining: UInt32?
    
    override init(TargetEndianness: EndianType)
    {
        super.init(TargetEndianness: TargetEndianness,
                   Id: .UserLeaving,
                   Len: PmsgUserLeaving.DefaultLen,
                   Ref: PmsgUserLeaving.DefaultRef)
    }
    
    override init(pmsg: Pmsg)
    {
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        self.UsersRemaining = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        super.init(pmsg: pmsg)
    }
}
