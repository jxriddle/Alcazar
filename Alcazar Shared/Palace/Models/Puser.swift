//
//  PalaceUser.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public class Puser
{
    public static let NumPropCells = 9
    
    public var Id: UInt32?
    public var Y: UInt16?
    public var X: UInt16?
    public var PropIdList: [UInt32]
    public var PropCrcList: [UInt32]
    public var RoomId: UInt16?
    public var Face: UInt16?
    public var Color: UInt16?
    public var PropNum: UInt16?
    public var UsernameLen: UInt8
    public var UsernamePaddedLen: UInt8?
    public var Username: String
    public var Flags: UInt16?
    public var Prop: Pprop?
    
    init()
    {
        self.Username = ""
        self.UsernameLen = 0
        self.PropIdList = []
        self.PropCrcList = []
    }
    
    func LoadProps()
    {
        // TODO stub
    }
}
