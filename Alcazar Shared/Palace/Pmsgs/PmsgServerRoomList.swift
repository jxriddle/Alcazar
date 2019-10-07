//
//  PmsgGetRoomList.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/16/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgServerRoomList: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000000
    public static let DefaultRef: UInt32 = 0x00000000
    
    public var RoomList: [Proom]?
    
    override init(TargetEndianness: EndianType)
    {
        super.init(TargetEndianness: TargetEndianness,
                   Id: .ServerRoomList,
                   Len: PmsgServerRoomList.DefaultLen,
                   Ref: PmsgServerRoomList.DefaultRef)
    }
    
    override init(pmsg: Pmsg)
    {
        self.RoomList = []
        
        let roomCount = pmsg.Ref!
        if pmsg.Rep == nil ||
            pmsg.Rep!.count <= Pmsg.HeaderSizeInBytes {
            super.init(pmsg: pmsg)
            return
        }
        
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        for _ in 0 ..< roomCount {
            let room = Proom()
            
            room.Id = p.load(as: UInt32.self)
            p += MemoryLayout<UInt32>.stride
            
            room.Flags = UInt32(p.load(as: UInt16.self))
            p += MemoryLayout<UInt16>.stride
            
            room.UserCount = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            let roomNameLen = p.load(as: UInt8.self)
            p += MemoryLayout<UInt8>.stride
            
            let roomNamePaddedLen = (roomNameLen + (4 - (roomNameLen & 3))) - 1
            
            let roomNameData = Data(bytes: p, count: Int(roomNameLen))
            room.Name = String(data: roomNameData, encoding: .utf8)
            
            if (room.Name == nil) {
                room.Name = String(data: roomNameData, encoding: .windowsCP1252)
            }
            
            p += Int(roomNamePaddedLen)
            
            self.RoomList!.append(room)
        }
        
        super.init(pmsg: pmsg)
    }
}
