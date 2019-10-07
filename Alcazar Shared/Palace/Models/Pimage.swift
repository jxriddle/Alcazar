//
//  Pimage.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/27/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

public class Pimage
{
    private var loadCompletedHandler: ((Pimage) -> Void)?
    
    var Id: UInt16?
    var X: UInt16?
    var Y: UInt16?
    var Width: UInt16?
    var Height: UInt16?
    var ImageData: Data?
    var TargetEndianness: EndianType?
    var TransparencyIndex: UInt16?
    var NameLen: UInt8?
    var Name: String?
    var Filename: String?
    
    func Load(from httpServer: String, completion: @escaping (Pimage) -> Void)
    {
        if self.Name == nil {
            return
        }
        
        self.loadCompletedHandler = completion
        
        let httpClient = AppHttpClient()
        let url = httpServer + self.Name!
        httpClient.FetchAsync(url: url, additionalHeaders: [:], completion: finishLoadingImage)
    }
    
    private func finishLoadingImage(data: Data)
    {
        self.ImageData = data
        
        if self.loadCompletedHandler != nil {
            DispatchQueue.main.async {
                self.loadCompletedHandler!(self)
            }
        }
    }
}
