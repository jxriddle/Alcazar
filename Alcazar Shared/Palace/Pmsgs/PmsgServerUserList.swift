//
//  PmsgAllUserList.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/25/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgServerUserList: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    var UserList: [Puser]?
    
    override init(TargetEndianness: EndianType)
    {
        super.init(TargetEndianness: TargetEndianness,
                   Id: .ServerUserList,
                   Len: PmsgServerUserList.DefaultLen,
                   Ref: PmsgServerUserList.DefaultRef)
    }
    
    override init(pmsg: Pmsg)
    {
        self.UserList = []
        
        let userCount = pmsg.Ref!
        if pmsg.Rep == nil ||
            pmsg.Rep!.count <= Pmsg.HeaderSizeInBytes {
            super.init(pmsg: pmsg)
            return
        }
        
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        for _ in 0 ..< userCount {
            let user = Puser()
            
            user.Id = p.load(as: UInt32.self)
            p += MemoryLayout<UInt32>.stride
            
            user.Flags = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            user.RoomId = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            user.UsernameLen = p.load(as: UInt8.self)
            p += MemoryLayout<UInt8>.stride
            
            let usernamePaddedLen = (user.UsernameLen + (4 - (user.UsernameLen & 3))) - 1
            
            let usernameData = Data(bytes: p, count: Int(usernamePaddedLen))
            //user.Username = String(data: usernameData, encoding: .utf8)
            
            //if (user.Username == nil) {
                let username = String(data: usernameData, encoding: .windowsCP1252)
            //}
            user.Username = username!
            
            p += Int(usernamePaddedLen)
            
            self.UserList!.append(user)
        }
        
        super.init(pmsg: pmsg)
    }
}
