//
//  PmsgLogon.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/17/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public class PmsgLogon: Pmsg
{
    public static let DefaultLen: UInt32 = 0x00000080
    public static let DefaultRef: UInt32 = 0x00000000
    
    public static let ReservedLen = 6
    
    private var sUsernameLen: UInt8 {
        return UInt8(self.sUsername.length)
    }
    
    private var sUsername: String {
        get {
            var res = self.username.substring(to: Pclient.MaxUsernameLen - 1)
            if res.length <= 0 {
                res = "Alcazar User"
            }
            
            return res
        }
    }
    
    private var sWizpass: String {
        get {
            return self.wizpass.substring(to: Pclient.MaxWizpassLen - 1)
        }
    }
    
    public var regCrc: UInt32
    public var regCounter: UInt32
    public var usernameLen: UInt8
    public var username: String
    public var wizpassLen: UInt8
    public var wizpass: String
    public var flags: PflagAuxOptions
    public var puidCounter: UInt32
    public var puidCrc: UInt32	
    public var demoElapsed: UInt32
    public var totalElapsed: UInt32
    public var demoLimit: UInt32
    public var initialRoomId: UInt16
    public var reserved: String
    public var uploadRequestedProtocolVersion: UInt32
    public var uploadCapabilities: PcapUlOptions
    public var downloadCapabilities: PcapDlOptions
    public var engineCapabilities2d: PcapEngine2dOptions
    public var graphicsCapabilities2d: PcapGraph2dOptions
    public var graphicsCapabilities3d: PcapGraph3dOptions
    
    convenience init(TargetEndianness: EndianType, username: String, wizpass: String, initialRoomId: UInt16)
    {
        self.init(TargetEndianness: TargetEndianness, username: username, wizpass: wizpass, initialRoomId: initialRoomId, regCounter: 0, regCrc: 0, puidCounter: 0, puidCrc: 0)
    }
    
    init(TargetEndianness: EndianType, username: String, wizpass: String, initialRoomId: UInt16, regCounter: UInt32, regCrc: UInt32, puidCounter: UInt32, puidCrc: UInt32)
    {
        self.username = username
        self.usernameLen = UInt8(username.length)
        self.wizpass = wizpass
        self.wizpassLen = UInt8(wizpass.length)
        self.initialRoomId = initialRoomId
        self.regCounter = regCounter
        self.regCrc = regCrc
        self.puidCounter = puidCounter
        self.puidCrc = puidCrc
        self.flags = [.authenticate, .win32]
        self.demoElapsed = 0x00011940
        self.totalElapsed = 0x00011940
        self.demoLimit = 0x00011940
        self.reserved = Pclient.ClientIdent
        self.uploadRequestedProtocolVersion = 0
        self.uploadCapabilities = [.palaceAssets, .httpFiles]
        self.downloadCapabilities = [.palaceAssets, .palaceFiles, .httpFiles, .httpFilesExtended]
        self.engineCapabilities2d = [.palace2dEngine]
        self.graphicsCapabilities2d = [.gif87]
        self.graphicsCapabilities3d = []
        
        super.init(TargetEndianness: TargetEndianness, Id: .Logon, Len: PmsgLogon.DefaultLen, Ref: PmsgLogon.DefaultRef)
    }
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        self.regCrc = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.regCounter = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        let usernameLenTmp = p.load(as: UInt8.self)
        self.usernameLen = usernameLenTmp
        p += MemoryLayout<UInt8>.stride
        
        let usernameData = Data(bytes: p, count: Int(usernameLenTmp))
        self.username = String(bytes: usernameData, encoding: .utf8)!
        p += Pclient.MaxUsernameLen
        
        let wizpassLenTmp = p.load(as: UInt8.self)
        self.wizpassLen = wizpassLenTmp
        p += MemoryLayout<UInt8>.stride
        
        let wizpassData = Data(bytes: p, count: Int(wizpassLenTmp))
        self.wizpass = String(bytes: wizpassData, encoding: .utf8)!
        p += Pclient.MaxWizpassLen
        
        self.puidCounter = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.puidCrc = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.flags = PflagAuxOptions(rawValue: p.load(as: UInt32.self))
        p += MemoryLayout<UInt32>.stride
        
        self.demoElapsed = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.totalElapsed = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.demoLimit = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.initialRoomId = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        let reservedData = Data(bytes: p, count: PmsgLogon.ReservedLen)
        self.reserved = String(bytes: reservedData, encoding: .utf8)!
        p += PmsgLogon.ReservedLen
        
        self.uploadRequestedProtocolVersion = p.load(as: UInt32.self)
        p += MemoryLayout<UInt32>.stride
        
        self.uploadCapabilities = PcapUlOptions(rawValue: p.load(as: UInt32.self))
        p += MemoryLayout<UInt32>.stride
        
        self.downloadCapabilities = PcapDlOptions(rawValue: p.load(as: UInt32.self))
        p += MemoryLayout<UInt32>.stride
        
        self.engineCapabilities2d = PcapEngine2dOptions(rawValue: p.load(as: UInt32.self))
        p += MemoryLayout<UInt32>.stride
        
        self.graphicsCapabilities2d = PcapGraph2dOptions(rawValue: p.load(as: UInt32.self))
        p += MemoryLayout<UInt32>.stride
        
        self.graphicsCapabilities3d = PcapGraph3dOptions(rawValue: p.load(as: UInt32.self))
        
        super.init(pmsg: pmsg)
    }
    
    override public func toData() -> Data
    {
        var rep = super.toData()
        
        rep.appendUInt32(self.regCrc, endianness: self.TargetEndianness)
        rep.appendUInt32(self.regCounter, endianness: self.TargetEndianness)
        
        rep.append(self.sUsernameLen)
        rep.append(self.sUsername.data(using: String.Encoding.utf8)!)
        rep.append(0) // null byte
        for _ in 0 ..< (Pclient.MaxUsernameLen - 1) - sUsername.length {
            rep.append(0)
        }
        
        rep.append(self.wizpassLen)
        rep.append(self.sWizpass.data(using: String.Encoding.utf8)!)
        rep.append(0) // null byte
        for _ in 0 ..< (Pclient.MaxWizpassLen - 1) - sWizpass.length {
            rep.append(0)
        }
        
        rep.appendUInt32(self.flags.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.puidCounter, endianness: self.TargetEndianness)
        rep.appendUInt32(self.puidCrc, endianness: self.TargetEndianness)
        rep.appendUInt32(self.demoElapsed, endianness: self.TargetEndianness)
        rep.appendUInt32(self.totalElapsed, endianness: self.TargetEndianness)
        rep.appendUInt32(self.demoLimit, endianness: self.TargetEndianness)
        rep.appendUInt16(self.initialRoomId, endianness: self.TargetEndianness)
        rep.append(self.reserved.data(using: String.Encoding.utf8)!)
        rep.appendUInt32(self.uploadRequestedProtocolVersion, endianness: self.TargetEndianness)
        rep.appendUInt32(self.uploadCapabilities.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.downloadCapabilities.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.engineCapabilities2d.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.graphicsCapabilities2d.rawValue, endianness: self.TargetEndianness)
        rep.appendUInt32(self.graphicsCapabilities3d.rawValue, endianness: self.TargetEndianness)
        
        return rep
    }
}
