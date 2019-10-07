//
//  PalaceSearchField.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/9/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class PalaceSearchField: NSSearchField
{
    func doInit()
    {
        self.sendsWholeSearchString = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInit()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        doInit()
    }
}
