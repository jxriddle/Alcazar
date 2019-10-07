//
//  PmsgUserList.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/16/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgRoomUserList: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    public var UserList: [Puser]?
    
    override init(pmsg: Pmsg)
    {
        self.UserList = []
        
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        for _ in 0 ..< pmsg.Ref! {
            let user = PmsgUserNew.UserNew(pointer: p)
            p += PmsgUserNew.SegmentSize
            self.UserList!.append(user)
        }
        
        super.init(pmsg: pmsg)
    }
}
