//
//  PalaceRoom.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public class Proom
{
    var Id: UInt32?
    var StatusMessage: String?
    var Flags: UInt32?
    var Face: UInt32?
    var NameLen: UInt8?
    var Name: String?
    var ArtistNameLen: UInt8?
    var ArtistName: String?
    var Password: String?
    var HotspotCount: UInt16?
    var Hotspots: [String]
    var ImageCount: UInt16?
    var DrawCommandsCount: UInt16?
    var DrawCommands: [String]
    var UserCount: UInt16?
    var LoosePropCount: UInt16?
    var LooseProps: [String]
    var Description: String?
    var BackgroundImage: Pimage
    var UserList: [Puser]
    var ImageList: [Pimage]?
    var ChatBubbleList: [PchatBubble]?
    
    init()
    {
        self.Hotspots = []
        self.LooseProps = []
        self.DrawCommands = []
        self.UserList = []
        self.ChatBubbleList = []
        self.BackgroundImage = Pimage()
    }
    
    static func Room(with roomId: UInt32, roomList: [Proom]) -> Proom?
    {
        let i: Int?
        if (0 < roomId) {
            i = roomList.index(where: { (room) -> Bool in
                room.Id == roomId
            })
        }
        else {
            // else outside room user xtalk?
            i = nil
        }
        
        let room: Proom?
        if (i != nil) {
            room = roomList[i!]
        }
        else {
            room = nil
        }
        
        return room
    }
    
    func User(with userId: UInt32) -> Puser?
    {
        let i: Int?
        if (0 < userId) {
            i = self.UserList.index(where: { (user) -> Bool in
                user.Id == userId
            })
        }
        else {
            i = nil
        }
        
        let user: Puser?
        if (i != nil) {
            user = self.UserList[i!]
        }
        else {
            user = nil
        }
        
        return user
    }
}
