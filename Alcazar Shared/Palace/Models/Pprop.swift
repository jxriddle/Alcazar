//
//  Pprop.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/16/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

public class Pprop
{
    var ImageData: Data?
    private var completion: ((Data) -> Void)?
    
    public func Load()
    {
        
    }
    
    public func FinishLoad(data: Data)
    {
        if self.completion != nil {
            self.completion!(data)
        }
    }
}
