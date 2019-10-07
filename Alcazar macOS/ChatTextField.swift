//
//  ChatTextField.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/31/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

@IBDesignable
class ChatTextField: NSTextField, NSTextFieldDelegate
{
    //init() {
        //self.cell.set
    //    super.init
    //}
    
    @IBInspectable var paddingLeft: CGFloat = 0
    {
        didSet {
            //self.layer.
        }
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        //NSColor.yellow.setFill()
        //NSRectFill(dirtyRect)
    }
    
    func textFieldDidBeginEditing()
    {
        //performSegue(withIdentifier: "ShowLogView", sender: self)
        
    }
}
