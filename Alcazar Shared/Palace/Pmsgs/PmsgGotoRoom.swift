//
//  PmsgGotoRoom.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/15/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgGotoRoom: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000002
    public static let DefaultRef: UInt32 = 0x00000000
    
    public var RoomId: UInt16
    
    init(TargetEndianness: EndianType, RoomId: UInt16)
    {
        self.RoomId = RoomId
        super.init(TargetEndianness: TargetEndianness,
                   Id: .GotoRoom,
                   Len: PmsgGotoRoom.DefaultLen,
                   Ref: PmsgGotoRoom.DefaultRef)
    }
    
    override public func toData() -> Data
    {
        var rep = super.toData()
        
        rep.appendUInt16(self.RoomId, endianness: self.TargetEndianness)
        
        return rep
    }
}
