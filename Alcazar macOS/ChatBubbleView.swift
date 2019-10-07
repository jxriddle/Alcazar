//
//  ChatBubble.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/11/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class ChatBubbleView: NSView {
    var message: Pmessage?
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(frame: CGRect, timer: Timer, message: Pmessage) {
        self.init(frame: frame)
        self.message = message
        self.timer = timer
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        if self.message == nil || self.message!.user == nil {
            return
        }
        
        let rounding: CGFloat = 0.02 * dirtyRect.width
        
        let bubbleFrame = CGRect(x: 0, y: 0, width: dirtyRect.width, height: 2/3 * dirtyRect.height)
        
        let bubblePath = NSBezierPath(roundedRect: bubbleFrame, xRadius: rounding, yRadius: rounding)
        //let color = NSColor
        let color = MainView.RoomColors[Int(self.message!.user!.Color!)]
        
        color!.setStroke()
        color!.setFill()
        bubblePath.stroke()
        bubblePath.fill()
        
        let context = NSGraphicsContext.current()
        
        let cgContext = context!.cgContext
        
        if self.message!.user!.Color == nil {
            cgContext.setFillColor(color!.cgColor)
        }
        else {
            cgContext.setFillColor(NSColor.white.cgColor)
        }
        
        let attributes: [String: Any] = [
            NSFontAttributeName: NSFont(name: "Helvetica Bold", size: 14)!
        ]
        
        let nsText = NSAttributedString(string: self.message!.content, attributes: attributes)
        let textFrame = NSRect(x: dirtyRect.origin.x, y: dirtyRect.origin.y, width: dirtyRect.size.width, height: dirtyRect.size.height)
        
        nsText.draw(in: textFrame)
        //let textSize = nsText.size()
        
        //cgContext.addEllipse(in: <#T##CGRect#>)
        //cgContext!.beginPath()
        //cgContext!.move(to: CGPoint(x: bubbleFrame.minX + 1/3 * bubbleFrame.width, y: bubbleFrame.maxY))
        
        //cgContext!.addArc(tangent1End: CGPoint, tangent2End: CGPoint(), radius: CGFloat())
    }
}
