//
//  AppImage.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/27/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

/*
class AppImage
{
    static let kBmpHeaderSize = 8
    static let kBitsPerComponent = 8
    
    static func MaskFromData(endian: EndianType, data: Data) -> CGImage?
    {
        if data.count < AppImage.kBmpHeaderSize {
            return nil
        }
        
        let pBuf = data.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: data.count) }
        
        let p = UnsafeRawPointer(pBuf.baseAddress!)
        
        let width: UInt16?
        if endian == .BigEndian {
            width = CFSwapInt16BigToHost(p.load(as: UInt16.self))
        }
        else if endian == .LittleEndian {
            width = CFSwapInt16LittleToHost(p.load(as: UInt16.self))
        }
        else {
            width = nil
            return nil
        }
        
        let height: UInt16?
        if endian == .BigEndian {
            height = CFSwapInt16BigToHost(p.load(as: UInt16.self))
        }
        else if endian == .LittleEndian {
            height = CFSwapInt16BigToHost(p.load(as: UInt16.self))
        }
        else {
            height = nil
            return nil
        }
        
        guard Int(width!) * Int(height!) + AppImage.kBmpHeaderSize <= data.count else {
            // data is not large enough to hold width * height
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let bitmapContext = CGContext(data: nil, width: Int(width!), height: Int(height!), bitsPerComponent: kBitsPerComponent, bytesPerRow: Int(width!), space: colorSpace, bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue) else {
            
            // context is nil
            return nil
        }
        
        guard let image = bitmapContext.makeImage() else {
            return nil
        }
        
        return image
    }
    
    static func processTransparency(data: Data)
    {
        
    }
} */
