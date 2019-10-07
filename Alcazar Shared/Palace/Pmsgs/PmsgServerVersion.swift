//
//  PmsgServerVersion.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/8/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class PmsgServerVersion: Pmsg {
    public var ServerVersion: Int {
        get {
            if self.Ref != nil {
                return Int(self.Ref!)
            }
            else {
                return 0
            }
        }
    }
}
