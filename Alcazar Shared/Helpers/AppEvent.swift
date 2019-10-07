//
//  AppEvent.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/28/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

class AppEvent
{
    typealias AppEventHandler = (Any) -> Void
    
    private var eventHandlerList = [AppEventHandler]()
    
    func addHandler(handler: @escaping AppEventHandler)
    {
        eventHandlerList.append(handler)
    }
    
    func raise(sender: Any)
    {
        for handler in eventHandlerList {
            handler(sender)
        }
    }
}
