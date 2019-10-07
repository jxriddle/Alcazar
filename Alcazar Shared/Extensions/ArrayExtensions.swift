//
//  ArrayExtensions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/8/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

extension Array where Element == Proom {
    mutating func Remove(with roomId: UInt32) -> Proom? {
        let index = self.index(where: { (item) -> Bool in
            item.Id! == roomId
        })
        
        let room: Proom?
        if index != nil {
            room = self.remove(at: index!)
        }
        else {
            room = nil
        }
        
        return room
    }
    
    mutating func Room(with roomId: UInt32) -> Proom?
    {
        let i: Int?
        if (0 < roomId) {
            i = self.index(where: { (room) -> Bool in
                room.Id == roomId
            })
        }
        else {
            i = nil
        }
        
        let room: Proom?
        if (i != nil) {
            room = self[i!]
        }
        else {
            room = nil
        }
        
        return room
    }
}

extension Array where Element == Puser {
    mutating func Remove(with userId: UInt32) -> Puser? {
        let index = self.index(where: { (item) -> Bool in
            item.Id! == userId
        })
        
        let user: Puser?
        if index != nil {
            user = self.remove(at: index!)
        }
        else {
            user = nil
        }
        
        return user
    }
    
    mutating func User(with userId: UInt32) -> Puser?
    {
        let i: Int?
        if (0 < userId) {
            i = self.index(where: { (user) -> Bool in
                user.Id == userId
            })
        }
        else {
            i = nil
        }
        
        let user: Puser?
        if (i != nil) {
            user = self[i!]
        }
        else {
            user = nil
        }
        
        return user
    }
}
