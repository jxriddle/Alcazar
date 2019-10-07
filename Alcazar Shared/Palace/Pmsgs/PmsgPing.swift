//
//  PmsgPing.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/18/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgPing: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    override init(pmsg: Pmsg)
    {
        super.init(pmsg: pmsg)
    }
    
    override init(TargetEndianness: EndianType)
    {
        super.init(TargetEndianness: TargetEndianness,
                   Id: .Ping,
                   Len: PmsgPing.DefaultLen,
                   Ref: PmsgPing.DefaultRef)
    }
}
