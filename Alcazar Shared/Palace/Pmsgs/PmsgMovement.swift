//
//  PmsgMove.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/3/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgMovement: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000004
    public static let DefaultRef: UInt32 = 0x00000000
    
    var X: UInt16?
    var Y: UInt16?
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        self.Y = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        self.X = p.load(as: UInt16.self)
        //p += MemoryLayout<UInt16>.stride
        
        super.init(pmsg: pmsg)
    }
    
    init(TargetEndianness: EndianType, X: UInt16, Y: UInt16)
    {
        self.X = X
        self.Y = Y
        super.init(TargetEndianness: TargetEndianness,
                   Id: .Movement,
                   Len: PmsgMovement.DefaultLen,
                   Ref: PmsgMovement.DefaultRef)
    }
    
    override public func toData() -> Data
    {
        var rep = super.toData()
        
        rep.appendUInt16(self.Y!, endianness: self.TargetEndianness)
        rep.appendUInt16(self.X!, endianness: self.TargetEndianness)
        
        return rep
    }
}
