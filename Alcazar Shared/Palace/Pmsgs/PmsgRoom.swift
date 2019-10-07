//
//  PmsgRoom.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/22/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgRoom: Pmsg
{
    static let DefaultLen: UInt32 = 0x00000000
    static let DefaultRef: UInt32 = 0x00000000
    static let SegmentSize = 40
    
    var room: Proom?
    
    override init(pmsg: Pmsg)
    {
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        self.room = Proom()
        
        // 40 bytes of offsets and metadata for room
        self.room!.Flags = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.room!.Face = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.room!.Id = UInt32(p.load(as: UInt16.self))
        p += MemoryLayout<UInt16>.stride
        
        let roomNameOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let backgroundImageNameOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let artistNameOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let passwordOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let hotspotCount = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let hotspotOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        self.room!.ImageCount = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let backgroundImageOffset = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        self.room!.DrawCommandsCount = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let firstDrawCommand = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        self.room!.UserCount = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        self.room!.LoosePropCount = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let firstLooseProp = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let _ = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let roomDataLen = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let roomDataBaseAddress = p
        
        //let paddingLen = Int(self.Len!) - Int(roomDataLen) - 40
        
        // Room Name
        p = roomDataBaseAddress + Int(roomNameOffset)
        room!.NameLen = p.load(as: UInt8.self)
        p += MemoryLayout<UInt8>.stride
        
        let roomNameData = Data(bytes: p, count: Int(room!.NameLen!))
        room!.Name = String(data: roomNameData, encoding: .utf8)
        
        if room!.Name == nil {
            room!.Name = String(data: roomNameData, encoding: .windowsCP1252)
        }
        
        // Background Image Name
        p = roomDataBaseAddress + Int(backgroundImageNameOffset)
        
        room!.BackgroundImage.NameLen = p.load(as: UInt8.self)
        p += MemoryLayout<UInt8>.stride
        
        let backgroundImageNameData = Data(bytes: p, count: Int(room!.BackgroundImage.NameLen!))
        room!.BackgroundImage.Name = String(data: backgroundImageNameData, encoding: .utf8)
        
        if room!.BackgroundImage.Name == nil {
            room!.BackgroundImage.Name = String(data: backgroundImageNameData, encoding: .windowsCP1252)
        }
        
        // TODO if URI Encode Image Names?
        // room.ImageName = UrlEscapeChars(room.ImageName)
        
        // Other Images
        /*
        room!.ImageList = []
        p = roomDataBaseAddress + Int(imageOffset)
        for _ in 0 ..< Int(room!.ImageCount!) {
            let image = Pimage()
            
            // refCon
            let _ = p.load(as: UInt32.self)
            p += MemoryLayout<UInt32>.stride
            
            image.Id = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            let picNameOffset = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            image.TransparencyIndex = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            // reserved
            let _ = p.load(as: UInt16.self)
            p += MemoryLayout<UInt16>.stride
            
            p = roomDataBaseAddress + Int(picNameOffset)
            image.NameLen = p.load(as: UInt8.self)
            p += MemoryLayout<UInt8>.stride
            
            // TODO if URI encoding on image name?
            let imageNameBytes = Data(bytes: p, count: Int(image.NameLen!))
            p += Int(image.NameLen!)
            
            image.Name = String(data: imageNameBytes, encoding: .utf8)
            
            if image.Name == nil {
                image.Name = String(data: imageNameBytes, encoding: .windowsCP1252)
            }
            
            p += 12 // ?
            
            //image.LoadImage(url: image.Name!)
            //self.room!.ImageList!.append(AppImage.MaskFromData(endian: TargetEndianness, data: <#T##Data#>)!)
        }
        */
        
        super.init(pmsg: pmsg)
    }
}
