//
//  PalaceEncryption.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public class Pcrypto
{
    static let LUT_COUNT = 512
    static let LUT_MAX = 256
    static let PLAINTEXT_LIMIT = 254
    
    private var lut: [Int16]
    private var seed_: Int32 = 1
    private var seed: Int32 {
        get {
            if (self.seed_ == 0) {
                return 1
            }
            
            return self.seed_
        }
        
        set {
            self.seed_ = newValue
        }
    }


    init()
    {
        self.lut = Array(repeating: Int16(0), count: Int(Pcrypto.LUT_COUNT))
        //let savedSeed = self.seed
        self.seed = 0xa2c2a
        
        for i in 0 ..< self.lut.count {
            self.lut[i] = int16Random(max: Pcrypto.LUT_MAX)
        }
        
        //self.seed = savedSeed
        self.seed = 0
    }
    
    public func ResetState()
    {
        self.seed = 0
    }
    
    private func int32Random() -> Int32
    {
        let quotient = self.seed_ / 0x1f31d
        let remainder = self.seed_ % 0x1f31d
        let a = 0x41a7 &* remainder &- 0xb14 &* quotient
        if (0 < a) {
            self.seed_ = a
        }
        else {
            self.seed_ = a &+ 0x7fffffff
        }
        
        return self.seed_
    }
    
    private func doubleRandom() -> Double
    {
        return Double(Double(int32Random()) / Double(0x7fffffff))
    }
    
    private func int16Random(max: Int) -> Int16
    {
        let dbl = doubleRandom()
        let i32 = Int32(dbl * Double(max))
        return Int16(i32)
    }
    
    private func int8Random(max: Int) -> Int8
    {
        let dbl = doubleRandom()
        let i16 = Int16(dbl * Double(max))
        return Int8(i16)
    }
    
    func Encrypt(plaintext: String) -> [UInt8]
    {
        if plaintext.length <= 0 {
            return [UInt8]()
        }
        
        let actualPlaintext: String
        if Pcrypto.PLAINTEXT_LIMIT < plaintext.length {
            actualPlaintext = plaintext.substring(to: Pcrypto.PLAINTEXT_LIMIT)
        }
        else {
            actualPlaintext = plaintext
        }
        
        let plaintextBytes = [UInt8](actualPlaintext.utf8)
        //let plaintextBytes = plaintext.utf8.map { UInt8($0) }
        var cipherBytes: [UInt8] = [UInt8](repeating: 0, count: plaintextBytes.count) // = Array(repeating: nil, count: plaintext.characters.count) as! [UInt8]
        
        var lastChar: UInt8 = 0
        var rc = 0
        for i in (0 ..< actualPlaintext.length).reversed() {
            cipherBytes[i] = UInt8(Int16(plaintextBytes[i]) ^ lut[rc] ^ Int16(lastChar))
            rc += 1
            lastChar = UInt8(Int16(cipherBytes[i]) ^ lut[rc])
            rc += 1
        }
        
        // this seems to be necessary.
        cipherBytes.append(0)
        
        return cipherBytes
    }
    
    func Decrypt(cipherBytes: [UInt8]) -> String?
    {
        if cipherBytes.count <= 0 {
            return nil
        }
        
        //let ciphertextBytes: [UInt8] = cipher.utf8.map { UInt8($0) }
        var plaintextBytes: [UInt8] = [UInt8](repeating: 0, count: cipherBytes.count)
        // Array(repeating: nil, count: ciphertext.characters.count) as! [UInt8]
        var lastChar: UInt8 = 0
        var rc = 0
        for i in (0 ..< cipherBytes.count).reversed() {
            plaintextBytes[i] = UInt8(Int16(cipherBytes[i]) ^ lut[rc] ^ Int16(lastChar))
            rc += 1
            lastChar = UInt8(Int16(cipherBytes[i]) ^ lut[rc])
            rc += 1
        }
        //plaintextBytes.append(0)
        
        if let plaintext = String(bytes: plaintextBytes, encoding: .utf8) {
            //return plaintext.trimmingCharacters(in: .newlines) //plaintext.trimmingCharacters(in: .whitespacesAndNewlines)
            return plaintext
        }
        else if let plaintext = String(bytes: plaintextBytes, encoding: .windowsCP1252) {
            //return plaintext.trimmingCharacters(in: .newlines) //plaintext.trimmingCharacters(in: .whitespacesAndNewlines)
            return plaintext
        }
        else {
            return nil
        }
        //let plaintext = String(cString: &plaintextBytes)
        //return plaintext
    }
}
