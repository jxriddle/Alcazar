//
//  PmsgXTalk.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/18/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgXTalk: Pmsg
{
    static let DefaultLen = 0x00000000
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
    private var crypto: Pcrypto

    init(pmsg: Pmsg, crypto: Pcrypto)
    {
        self.crypto = crypto
        
        self.Cipher = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        
        //let self.Cipher = [UInt8](pmsg.Rep!)
        var p = UnsafeRawPointer(self.Cipher!)
        p += Pmsg.HeaderSizeInBytes
        
        let cipherLen = p.load(as: UInt16.self) - UInt16(PmsgXTalk.cipherLenCorrection)
        p += MemoryLayout<UInt16>.stride
        
        let cipherData = Data(bytes: p, count: Int(cipherLen))
        //let cipherBytes = cipherData.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: cipherData.count)) }
        let cipherBytes = [UInt8](cipherData)
        self.Message = self.crypto.Decrypt(cipherBytes: cipherBytes)
        
        super.init(pmsg: pmsg)
    }
    
    init(TargetEndianness: EndianType, Ref: UInt32, Message: String, crypto: Pcrypto)
    {
        self.crypto = crypto
        self.Message = Message
        self.Cipher = crypto.Encrypt(plaintext: self.Message!)
        
        super.init(TargetEndianness: TargetEndianness,
                   Id: .XTalk,
                   Len: UInt32(Message.lengthOfBytes(using: .windowsCP1252) + PmsgXTalk.cipherLenCorrection),
                   Ref: PmsgTalk.DefaultRef)
    }
    
    override public func toData() -> Data
    {
        var rep = super.toData()
        
        rep.appendUInt16(UInt16(self.Len!), endianness: self.TargetEndianness)
        rep.append(contentsOf: self.Cipher!)
        
        return rep
    }
}
