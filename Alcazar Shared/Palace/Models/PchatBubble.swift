//
//  PchatBubble.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/19/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

public class PchatBubble
{
    public var message: Pmessage?
    public var timer: Timer?
    //public var colorId: Int?
    
    init(message: Pmessage) {
        self.message = message
    }
}
