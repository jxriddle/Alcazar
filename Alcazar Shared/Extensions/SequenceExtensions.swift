//
//  SequenceExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

/*
extension Sequence where Iterator.Element == Character {
    
    /* extension accessible as function */
    func asByteArray() -> [UInt8] {
        return String(self).utf8.map { UInt8($0) }
    }
    
    /* or, as @LeoDabus pointed out below (thanks!),
     use a computed property for this simple case  */
    var byteArray : [UInt8] {
        return String(self).utf8.map { UInt8($0) }
    }
}
*/
