//
//  PmsgUserFace.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/8/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserFace: Pmsg {
    public var Face: UInt16?
    
    override init(pmsg: Pmsg) {
        let pmsgBytes = pmsg.Rep!.withUnsafeBytes { UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count) }
        
        var p = UnsafeRawPointer(pmsgBytes.baseAddress)!
        p += Pmsg.HeaderSizeInBytes
        
        self.Face = p.load(as: UInt16.self)
        p += MemoryLayout<UInt16>.stride
        
        super.init(pmsg: pmsg)
    }
}
