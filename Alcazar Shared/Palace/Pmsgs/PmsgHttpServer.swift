//
//  PmsgMediaServer.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/28/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgHttpServer: Pmsg
{
    static let DefaultLen: UInt32 = 0x00000000
    static let DefaultRef: UInt32 = 0x00000000
    let HttpServer: String?
    
    override init(pmsg: Pmsg)
    {
        let bytes = pmsg.Rep!.withUnsafeBytes { [UInt8](UnsafeBufferPointer<UInt8>(start: $0, count: pmsg.Rep!.count)) }
        
        var p = UnsafeRawPointer(bytes)
        p += Pmsg.HeaderSizeInBytes
        
        let pCstr = p.bindMemory(to: UInt8.self, capacity: Int(pmsg.Len!))
        let httpServer = String(cString: pCstr)
        self.HttpServer = httpServer
        
        super.init(pmsg: pmsg)
    }
}
