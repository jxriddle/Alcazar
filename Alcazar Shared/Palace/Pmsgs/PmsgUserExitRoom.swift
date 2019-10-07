//
//  PmsgUserExitRoom.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/24/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgUserExitRoom: Pmsg
{
    var UserId: UInt32 {
        get {
            if self.Ref != nil {
                return self.Ref!
            }
            else {
                return UInt32(0)
            }
        }
        
        set {
            self.Ref = newValue
        }
    }
    
    
    
    
}
