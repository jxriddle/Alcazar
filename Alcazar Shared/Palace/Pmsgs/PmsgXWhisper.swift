//
//  PmsgXWhisper.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/20/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgXWhisper: Pmsg
{
    static let DefaultLen = 0x00000004
    static let DefaultRef = 0x00000000
    
    //public static let cipherLenCorrection: Int16 = -3
    public static let cipherLenCorrection = 3
    
    public var Message: String?
    public var Cipher: [UInt8]?
    public var FromUserId: UInt32? {
        get {
            return self.Ref!
        }
        
        set {
            self.Ref = newValue
        }
    }
    
    public var ToUserId: UInt32?
    private var crypto: Pcrypto
    
    init(pmsg: Pmsg, crypto: Pcrypto)
    {
        self.crypto = crypto
        
        self.Cipher = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        var p = UnsafeRawPointer(self.Cipher!)
        p += Pmsg.HeaderSizeInBytes
        
        let cipherLen = p.load(as: UInt16.self) - UInt16(PmsgXWhisper.cipherLenCorrection)
        p += MemoryLayout<UInt16>.stride
        
        let cipherData = Data(bytes: p, count: Int(cipherLen))
        let cipherBytes = cipherData.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: cipherData.count)) }
        self.Message = self.crypto.Decrypt(cipherBytes: cipherBytes)
        
        super.init(pmsg: pmsg)
    }
    
    init(TargetEndianness: EndianType, Ref: UInt32, ToUserId: UInt32, Message: String, crypto: Pcrypto)
    {
        self.ToUserId = ToUserId
        self.crypto = crypto
        self.Message = Message
        self.Cipher = crypto.Encrypt(plaintext: self.Message!)
        super.init(TargetEndianness: TargetEndianness, Id: .XWhisper, Len: UInt32(Message.lengthOfBytes(using: .utf8) + PmsgXWhisper.cipherLenCorrection + PmsgXWhisper.DefaultLen), Ref: Ref)
    }
    
    override public func toData() -> Data
    {
        var rep = super.toData()
        
        rep.appendUInt32(self.ToUserId!, endianness: self.TargetEndianness)
        rep.appendUInt16(UInt16(Message!.lengthOfBytes(using: .utf8) + PmsgXWhisper.cipherLenCorrection), endianness: self.TargetEndianness)
        rep.append(contentsOf: self.Cipher!)
        
        return rep
    }
}
