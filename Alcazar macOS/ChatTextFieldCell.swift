//
//  ChatTextFieldCell.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/1/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class ChatTextFieldCell: NSTextFieldCell
{
    @IBInspectable var leftPadding: CGFloat = 30.0
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect
    {
        let rectInset = NSMakeRect(rect.origin.x + leftPadding, rect.origin.y, rect.size.width - leftPadding, rect.size.height)
        
        return super.drawingRect(forBounds: rectInset)
    }
}
