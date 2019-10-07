//
//  NSWindowExceptions.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/29/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}
