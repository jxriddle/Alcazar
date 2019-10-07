//
//  PmsgUserColor.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/8/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserColor: Pmsg {
    public static let NumUserColors: UInt16 = 16
    public static let UserColorOffset: UInt16 = PmsgUserColor.NumUserColors - 1
    
    public var Color: UInt16?
    
    override init(pmsg: Pmsg) {
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        //let actualUserColor = PmsgUserColor.UserColorOffset - p.load(as: UInt16.self)
        //self.Color = 0 <= actualUserColor && actualUserColor < PmsgUserColor.NumUserColors ? actualUserColor : 0
        self.Color = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        super.init(pmsg: pmsg)
    }
}
