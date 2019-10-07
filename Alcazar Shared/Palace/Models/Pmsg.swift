//
//  PalaceMsg.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public enum PmsgType: UInt32
{
    // == Server ====================================================
    case Nil                    = 0x00000000 // 0x6E696C20 // "nil "
    case UnknownServer          = 0x70736572 // "pser"
    case LittleEndianServer     = 0x72796974 // "ryit"
    case BigEndianServer        = 0x74697972 // "tiyr"
    case AltLogon               = 0x72657032 // "rep2"
    case ServerVersion          = 0x76657273 // "vers"
    case ServerInfo             = 0x73696E66 // "sinf"
    case UserStatus             = 0x75537461 // "uSta"
    case UserLoggedOnAndMax     = 0x6C6F6720 // "log "
    case HttpServerLocation     = 0x48545450 // "HTTP"
    case RoomDescription        = 0x726F6F6D // "room"
    case AltRoomDescription     = 0x73526F6D // "sRom"
    case RoomUserList           = 0x72707273 // "rprs"
    case ServerRoomList         = 0x724C7374 // "rLst"
    case RoomDescend            = 0x656E6472 // "endr"
    case UserNew                = 0x6E707273 // "nprs"
    case Ping                   = 0x70696E67 // "ping"
    case Pong                   = 0x706F6E67 // "pong"
    case XTalk                  = 0x78746C6B // "xtlk" (encrypted)
    case XWhisper               = 0x78776973 // "xwis" (encrypted)
    case Talk                   = 0x74616C6B // "talk" (unencrypted)
    case Whisper                = 0x77686973 // "whis" (unencrypted)
    case Movement               = 0x754C6F63 // "uLoc"
    case UserColor              = 0x75737243 // "usrC"
    case UserDescription        = 0x75737244 // "usrD"
    case UserFace               = 0x75737246 // "usrF"
    case UserProp               = 0x75737250 // "usrP"
    case UserRename             = 0x7573724E // "usrN"
    case UserLeaving            = 0x62796520 // "bye "
    case FileIncoming           = 0x7346696C // "sFil"
    case AssetIncoming          = 0x73417374 // "sAst"
    case UserExitRoom           = 0x65707273 // "eprs"
    case ServerUserList         = 0x754C7374 // "uLst"
    case DoorLock               = 0x6C6F636B // "lock"
    case DoorUnlock             = 0x756E6C6F // "unlo"
    case SpotState              = 0x73537461 // "sSta"
    case SpotMove               = 0x636F4C73 // "coLs"
    case PictMove               = 0x704C6F63 // "pLoc"
    case Draw                   = 0x64726177 // "draw"
    case PropMove               = 0x6D507270 // "mPrp"
    case PropDelete             = 0x64507270 // "dPrp"
    case PropNew                = 0x6E507270 // "nPrp"
    case AssetQuery             = 0x71417374 // "qAst"
    case NavError               = 0x73457272 // "sErr"
    case ConnectionError        = 0x646F776E // "down"
    case BlowThru               = 0x626C6F77 // "blow"
    case Authenticate           = 0x61757468 // "auth"
    // == Room =======================================================
    case GotoRoom               = 0x6E617652 // "navR"
    case Room                   = 0x30C6015D // "0..]"
    case SuperUser              = 0x73757372 // "susr"
    case Logon                  = 0x72656769 // "regi"
    case AssetRegi              = 0x72417374 // "rAst"
    case GlobalMessage          = 0x676D7367 // "gmsg"
    case RoomMessage            = 0x726D7367 // "rmsg"
    case SuperUserMessage       = 0x736D7367 // "smsg"
    case AuthResponse           = 0x61757472 // "autr"
}

public class Pmsg
{
    //public static var DefaultLen: UInt32 = 0x00000000
    //public static var DefaultRef: UInt32 = 0x00000000
    
    public static let HeaderSizeInBytes = 12
    public static let NumFieldsInHeader = 3
    public var TargetEndianness: EndianType = .Unknown
    public var Id: PmsgType?
    public var Len: UInt32?
    public var Ref: UInt32?
    public var Rep: Data?
    
    public var PartLen: UInt32 {
        get {
            if self.Rep == nil || self.Rep!.count < Pmsg.HeaderSizeInBytes {
                return 0
            }
            
            return UInt32(self.Rep!.count) - UInt32(Pmsg.HeaderSizeInBytes)
        }
    }

    //public var RawHeader: UnsafeRawPointer? // [UInt32]?
    //public var RawPayload: UnsafeRawPointer? // [UInt8]?
    //public var Rep: [UInt8]?
    
    init(pmsg: Pmsg)
    {
        self.TargetEndianness = pmsg.TargetEndianness
        self.Id = pmsg.Id
        self.Len = pmsg.Len
        self.Ref = pmsg.Ref
        self.Rep = pmsg.Rep
    }
    
    init(TargetEndianness: EndianType)
    {
        self.TargetEndianness = TargetEndianness
        self.Id = nil
        self.Len = nil
        self.Ref = nil
        self.Rep = self.toData()
    }
    
    init(TargetEndianness: EndianType, Id: PmsgType?, Len: UInt32?, Ref: UInt32?)
    {
        self.TargetEndianness = TargetEndianness
        self.Id = Id
        self.Len = Len
        self.Ref = Ref
        //Pmsg.Header(TargetEndianness: EndianType, Id: Id, Len: Len, Ref: Ref)
        self.Rep = self.toData()
    }
    /*
    init(TargetEndianness: EndianType, byteBuf: UnsafeBufferPointer<UInt8>)
    {
        self.TargetEndianness = TargetEndianness
        let pHeader = UnsafeRawPointer(byteBuf.baseAddress!)
        let Header = pHeader.bindMemory(to: UInt32.self, capacity: Pmsg.HeaderSizeInBytes)
        
        switch (TargetEndianness) {
        case .LittleEndian:
            self.Id = PmsgType(rawValue: CFSwapInt32LittleToHost(Header[0]))
            self.Len = CFSwapInt32LittleToHost(Header[1])
            self.Ref = CFSwapInt32LittleToHost(Header[2])
            break
        case .BigEndian:
            self.Id = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            self.Len = CFSwapInt32BigToHost(Header[1])
            self.Ref = CFSwapInt32BigToHost(Header[2])
            break
        case .Unknown:
            self.Id = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            self.Len = CFSwapInt32BigToHost(Header[1])
            self.Ref = CFSwapInt32BigToHost(Header[2])
            break
        }
        
        if 0 < self.Len! {
            let pPayload = UnsafeBufferPointer(start: byteBuf.baseAddress! + Pmsg.HeaderSizeInBytes, count: byteBuf.count - Pmsg.HeaderSizeInBytes)
            self.Rep = Data(buffer: pPayload)
        }
    } */
    
    init(TargetEndianness: EndianType, data: Data)
    {
        let bytes = [UInt8](data) //Buf = data.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: data.count)) }
        
        let pHeader = UnsafeRawPointer(bytes)
        let Header = pHeader.bindMemory(to: UInt32.self, capacity: Pmsg.NumFieldsInHeader)
        
        let pmsgType: PmsgType?
        let pmsgLen: UInt32
        let pmsgRef: UInt32
        
        switch (TargetEndianness) {
        case .LittleEndian:
            pmsgType = PmsgType(rawValue: CFSwapInt32LittleToHost(Header[0]))
            pmsgLen = CFSwapInt32LittleToHost(Header[1])
            pmsgRef = CFSwapInt32LittleToHost(Header[2])
            break
        case .BigEndian:
            pmsgType = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            pmsgLen = CFSwapInt32BigToHost(Header[1])
            pmsgRef = CFSwapInt32BigToHost(Header[2])
            break
        case .Unknown:
            pmsgType = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            //self.Len = CFSwapInt32BigToHost(Header[1])
            pmsgRef = CFSwapInt32BigToHost(Header[2])
            pmsgLen = 0 // ?
            break
        }
        
        //let pPayload = &bytes[Pmsg.HeaderSizeInBytes]
        //if (Pmsg.HeaderSizeInBytes < bytes.count && bytes.count <= Pmsg.HeaderSizeInBytes + Int(self.Len!)) {
            
            //pmsgRep.append([UInt8](Pmsg.Payload(data: data)))
        //}
        
        self.TargetEndianness = TargetEndianness
        self.Id = pmsgType
        self.Len = pmsgLen
        self.Ref = pmsgRef
        self.Rep = data //Pmsg.Payload(data: data)
    }
    
    public func Append(data: Data, len: Int)
    {
        var buf = data.withUnsafeBytes { [UInt8](UnsafeBufferPointer(start: $0, count: len)) } //[UInt8](repeating: 0, count: bufLen)
        
        if self.Rep == nil {
            self.Rep = Data()
        }
        
        self.Rep!.append(&buf, count: len)
    }
    
    public static func Header(TargetEndianness: EndianType, data: Data) -> Pmsg
    {
        let bytes = data.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: Pmsg.HeaderSizeInBytes)) }
        //self.init(TargetEndianness: TargetEndianness, bytes: bytes)
        
        let pHeader = UnsafeRawPointer(bytes)
        let Header = pHeader.bindMemory(to: UInt32.self, capacity: Pmsg.NumFieldsInHeader)
        
        let pmsgType: PmsgType?
        let pmsgLen: UInt32
        let pmsgRef: UInt32
        
        switch (TargetEndianness) {
        case .LittleEndian:
            pmsgType = PmsgType(rawValue: CFSwapInt32LittleToHost(Header[0]))
            pmsgLen = CFSwapInt32LittleToHost(Header[1])
            pmsgRef = CFSwapInt32LittleToHost(Header[2])
            break
        case .BigEndian:
            pmsgType = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            pmsgLen = CFSwapInt32BigToHost(Header[1])
            pmsgRef = CFSwapInt32BigToHost(Header[2])
            break
        case .Unknown:
            pmsgType = PmsgType(rawValue: CFSwapInt32BigToHost(Header[0]))
            //self.Len = CFSwapInt32BigToHost(Header[1])
            pmsgRef = CFSwapInt32BigToHost(Header[2])
            pmsgLen = 0 // ?
            break
        }
        
        return Pmsg(TargetEndianness: TargetEndianness, Id: pmsgType, Len: pmsgLen, Ref: pmsgRef)
    }
    
    public static func Payload(data: Data) -> Data
    {
        return Data(data.suffix(from: Pmsg.HeaderSizeInBytes))
    }
    
    public func Payload() -> Data
    {
        return Data(self.Rep!.suffix(from: Pmsg.HeaderSizeInBytes))
    }
    
    public func toData() -> Data
    {
        var rep = Data()
        rep.appendUInt32(self.Id!.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.Len!, endianness: self.TargetEndianness)
        rep.appendUInt32(self.Ref!, endianness: self.TargetEndianness)
        return rep
    }
}
