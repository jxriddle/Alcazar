//
//  DataExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/16/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

extension Data
{
    //var _isBigEndian = value.
    func dump() -> String
    {
        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ~_-!?/'.()")
        var res = ""
        
        let size = self.count
        let ndigits = 16
        let nseg = 8
        //let i = size
        //var j = 0
        var c0 = 0
        var c1 = 0
        let nlines = (size / ndigits) + (0 < (size % ndigits) ? 1 : 0)
        
        //fprintf(stderr, "Dumping buf with size: %ld\n", size);
        //for (j = 0; j < nlines; ++j) {
        for _ in 0 ..< nlines {
            //fprintf(stderr, "%08x  ", c0);
            res.append(String(format: "%08x  ", c0))
            //for (i = 0; i < ndigits; ++i) {
            for i in 0 ..< ndigits {
                if i % nseg == 0 && 0 < i && c0 < size {
                    //fprintf(stderr, " %02x ", buf.base[c0] & 0xff);
                    res.append(String(format: " %02x ", self[c0]))
                }
                else if size <= c0 {
                    //fprintf(stderr, "   ");
                    res.append("   ")
                }
                else {
                    //fprintf(stderr, "%02x ", self[c0] & 0xff)
                    res.append(String(format: "%02x ", self[c0] & 0xff))
                }
                c0 += 1
            }
            //for (i = 0; i < ndigits; ++i) {
            for i in 0 ..< ndigits {
                if i % nseg == 0 && 0 < i && c1 < size {
                    //fprintf(stderr, " ");
                    res.append(" ")
                }
                
                let ch = String(self[c1])
                //let charSet = [CharacterSet.alphanumerics, CharacterSet.punctuationCharacters]
                if (ch.rangeOfCharacter(from: characterSet) != nil) {
                    //ch.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil {
                    //ch.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil {
                    //fprintf(stderr, "%c", buf.base[c1] & 0xff);
                    res.append(String(format: "%c", self[c1] & 0xff))
                }
                else if (size <= c1) {
                    //fprintf(stderr, " ");
                    res.append(" ")
                }
                else {
                    //fprintf(stderr, ".");
                    res.append(".")
                }
                c1 += 1
            }
            //fprintf(stderr, "\n");
            res.append("\n")
        }
        
        return res
    }
    
    mutating func appendInt32(_ value: Int32, endianness: EndianType)
    {
        var endianValue = value
        
        if endianness == .LittleEndian {
            endianValue = value.littleEndian
        }
        else if endianness == .BigEndian {
            endianValue = value.bigEndian
        }
        
        let count = MemoryLayout<Int32>.size
        let bytePtr = withUnsafePointer(to: &endianValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        
        self.append(bytePtr.baseAddress!, count: count)
    }
    
    mutating func appendInt32(bigEndian value: Int32)
    {
        self.appendInt32(value, endianness: .BigEndian)
    }
    
    mutating func appendInt32(littleEndian value: Int32)
    {
        self.appendInt32(value, endianness: .LittleEndian)
    }
    
    mutating func appendUInt32(_ value: UInt32, endianness: EndianType)
    {
        var endianValue = value
        
        if endianness == .LittleEndian {
            endianValue = value.littleEndian
        }
        else if endianness == .BigEndian {
            endianValue = value.bigEndian
        }
        
        let count = MemoryLayout<UInt32>.size
        let bytePtr = withUnsafePointer(to: &endianValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        
        self.append(bytePtr.baseAddress!, count: count)
    }
    
    mutating func appendUInt32(bigEndian value: UInt32)
    {
        self.appendUInt32(value, endianness: .BigEndian)
    }
    
    mutating func appendUInt32(littleEndian value: UInt32)
    {
        self.appendUInt32(value, endianness: .LittleEndian)
    }
    
    mutating func appendInt16(_ value: Int16, endianness: EndianType)
    {
        var endianValue = value
        
        if endianness == .LittleEndian {
            endianValue = value.littleEndian
        }
        else if endianness == .BigEndian {
            endianValue = value.bigEndian
        }

        let count = MemoryLayout<Int16>.size
        let bytePtr = withUnsafePointer(to: &endianValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        
        self.append(bytePtr.baseAddress!, count: count)
    }
    
    mutating func appendInt16(bigEndian value: Int16)
    {
        self.appendInt16(value, endianness: .BigEndian)
    }
    
    mutating func appendInt16(littleEndian value: Int16)
    {
        self.appendInt16(value, endianness: .LittleEndian)
    }
    
    mutating func appendUInt16(_ value: UInt16, endianness: EndianType)
    {
        var endianValue = value
        
        if endianness == .LittleEndian {
            endianValue = value.littleEndian
        }
        else if endianness == .BigEndian {
            endianValue = value.bigEndian
        }
        
        let count = MemoryLayout<UInt16>.size
        let bytePtr = withUnsafePointer(to: &endianValue) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }

        self.append(bytePtr.baseAddress!, count: count)
    }
    
    mutating func appendUInt16(bigEndian value: UInt16)
    {
        self.appendUInt16(value, endianness: .BigEndian)
    }
    
    mutating func appendUInt16(littleEndian value: UInt16)
    {
        self.appendUInt16(value, endianness: .LittleEndian)
    }
}
