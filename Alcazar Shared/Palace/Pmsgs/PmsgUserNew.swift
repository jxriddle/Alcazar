//
//  PmsgUserNew.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/24/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserNew: Pmsg
{
    public static let SegmentSize = 124
    
    var User: Puser?
    
    static func UserNew(pointer: UnsafeRawPointer) -> Puser {
        let user: Puser = Puser()
        var p = pointer
        
        user.Id = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        user.Y = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        user.X = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        for _ in 0 ..< Puser.NumPropCells {
            user.PropIdList.append(p.load(as: UInt32.self))
            p += MemoryLayout<UInt32>.stride
            
            user.PropCrcList.append(p.load(as: UInt32.self))
            p += MemoryLayout<UInt32>.stride
        }
        
        user.RoomId = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        user.Face = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        //let actualUserColor = PmsgUserColor.UserColorOffset - p.load(as: UInt16.self)
        //user.Color = 0 <= actualUserColor && actualUserColor < PmsgUserColor.NumUserColors ? actualUserColor : 0
        user.Color = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        // Unknown
        //p += MemoryLayout<UInt16>.stride
        
        // Unknown
        p += MemoryLayout<UInt16>.stride + MemoryLayout<UInt16>.stride
        
        user.PropNum = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        if (user.PropNum! < UInt16(Puser.NumPropCells)) {
            user.PropIdList[Int(user.PropNum!)] = 0
            user.PropCrcList[Int(user.PropNum!)] = 0
        }
        
        let usernameLenTmp = p.load(as: UInt8.self)
        user.UsernameLen = usernameLenTmp
        p += MemoryLayout<UInt8>.stride
        
        //let count = Int(Pclient.MaxUsernameLen) - Int(usernameLenTmp)
        let usernameData = Data(bytes: p, count: Int(usernameLenTmp))
        //usernameData.append(0)
        var username = String(data: usernameData, encoding: String.Encoding.utf8)
        if username == nil {
            username = String(data: usernameData, encoding: String.Encoding.windowsCP1252)
        }
        user.Username = username!
        
        p += Pclient.MaxUsernameLen
        
        return user
    }
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        self.User = PmsgUserNew.UserNew(pointer: p)
        super.init(pmsg: pmsg)
    }
}
