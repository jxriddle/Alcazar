//
//  MainView.swift
//  Alcazar
//
//  Created by Jesse Riddle on 5/1/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class MainView: NSView, PclientDelegate {
    static let SmileyHeight = 45
    static let SmileyWidth = 45
    
    static let MaxPropWidth = 132
    static let MaxPropHeight = 132
    
    public var Client: Pclient?
    public var ChatQueue: AppQueue<Pmessage>?
    private var chatQueueTimer: Timer?
    private var ChatBubbles: [ChatBubbleView]?
    
    private var isDragging: Bool = false
    
    override var isFlipped: Bool {
        get {
            return true
        }
    }
    
    override var acceptsFirstResponder: Bool {
        get {
            return true
        }
    }
    
    public static let RoomColors: [Int: NSColor] = [
        0: NSColor.red,
        1: NSColor.red.blended(withFraction: 0.5, of: NSColor.orange)!,
        2: NSColor.orange,
        3: NSColor.yellow, //.blended(withFraction: 0.5, of: NSColor.black)!,
        4: NSColor.yellow.blended(withFraction: 0.3, of: NSColor.green)!,
        5: NSColor.yellow.blended(withFraction: 0.6, of: NSColor.green)!,
        6: NSColor.green,
        7: NSColor.green.blended(withFraction: 0.5, of: NSColor.cyan)!,
        8: NSColor.cyan,
        9: NSColor.cyan.blended(withFraction: 0.3, of: NSColor.blue)!,
        10: NSColor.cyan.blended(withFraction: 0.6, of: NSColor.blue)!,
        11: NSColor.blue,
        12: NSColor.blue.blended(withFraction: 0.5, of: NSColor.purple)!,
        13: NSColor.purple,
        14: NSColor.magenta,
        15: NSColor.magenta.blended(withFraction: 0.3, of: NSColor.red)!
    ]
    
    //var BackgroundImage: Pimage?
    var Smileys: NSImage?
    //var SmileysRef: NSBitmapImageRep?
    //var UserList: [Puser]?
    //var UserSelf: Puser?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //self.BackgroundImage = Pimage()
        //self.UserList = []
        //self.UserSelf = nil
        self.Smileys = NSImage(named: "defaultsmileys")
        self.ChatBubbles = []
        self.wantsLayer = true
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //self.BackgroundImage = Pimage()
        //self.UserList = []
        //self.UserSelf = nil
        self.Smileys = NSImage(named: "defaultsmileys")
        self.ChatBubbles = []
        self.wantsLayer = true
    }
    
    override func draw(_ dirtyRect: NSRect)
    {
        let context = NSGraphicsContext.current()
        let cgContext = context?.cgContext
        cgContext!.saveGState()
        
        if self.Client != nil && self.Client!.Room != nil {
            Swift.print("Drawing background...")
            draw(image: self.Client!.Room!.BackgroundImage, context: NSGraphicsContext.current())
            
            Swift.print("Drawing users...")
            for user in self.Client!.Room!.UserList {
                //Swift.print("Drawing user \(user.Username)")
                draw(user: user, context: NSGraphicsContext.current())
            }
            
            let message = self.ChatQueue!.dequeue()
            if message != nil {
                //let chatBubble = ChatBubble(message: Pmessage)
                self.Client!.Room!.ChatBubbleList!.append(PchatBubble(message: message!))
            }
            
            /*
            while currentMessage != nil {
                draw(message: currentMessage!, context: NSGraphicsContext.current())
                currentMessage = self.ChatQueue!.dequeue()
                self.needsDisplay = true
            }
            */
        }
        else {
            // Draw bookmarks grid?
        }
        
        cgContext!.restoreGState()
    }
    
    func draw(image: Pimage, context: NSGraphicsContext?) {
        if context == nil {
            Swift.print("Context is nil while drawing image!")
            return
        }
        
        let cgContext = context?.cgContext
        if cgContext == nil {
            Swift.print("cgContext is nil while drawing image!")
            return
        }
        
        //cgContext!.saveGState()
        
        if image.ImageData == nil {
            Swift.print("Image data is nil while drawing image!")
            return
        }
        
        let nsImage = NSImage(data: image.ImageData!)
        if nsImage == nil {
            Swift.print("nsImage is nil while drawing image!")
            return
        }
        
        let rect = NSRect(x: Int(image.X!), y: Int(image.Y!), width: Int(image.Width!), height: Int(image.Height!))
        
        nsImage!.draw(in: rect)
        
        //let nsImageReps = nsImage!.representations
        //let imageSize = nsImageReps.reduce(CGSize.zero, { (size: CGSize, rep: NSImageRep) -> CGSize in
            //CGSize(width: max(size.width, CGFloat(rep.pixelsWide)), height: max(size.height, CGFloat(rep.pixelsHigh)))
        //})
        
        //var cgImageFrame = NSRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        //let cgImage = nsImage!.cgImage(forProposedRect: &cgImageFrame, context: context, hints: nil)
        
        //cgContext!.draw(cgImage!, in: cgImageFrame)
        
        //cgContext!.restoreGState()
    }
    
    func draw(user: Puser, context: NSGraphicsContext?) {
        if context == nil {
            Swift.print("Context is nil while drawing user!")
            return
        }
        
        let cgContext = context?.cgContext
        if cgContext == nil {
            Swift.print("cgContext is nil while drawing user!")
            return
        }
        
        //cgContext!.saveGState()
        
        let spriteWidth = MainView.SmileyWidth
        let spriteHeight = MainView.SmileyHeight
        
        let userColorOff = Int(self.Smileys!.height) - (spriteHeight * (Int(user.Color!) + 1))
        let userFaceOff = spriteWidth * Int(user.Face!)
        
        let croppedFaceFrame = CGRect(x: userFaceOff, y: userColorOff, width: spriteWidth, height: spriteHeight)
        
        let croppedFaceSize = NSSize(width: spriteWidth, height: spriteHeight)
        
        let croppedSmiley = NSImage(size: croppedFaceSize)
        
        croppedSmiley.lockFocus()
        
        self.Smileys!.draw(in: NSMakeRect(0, 0, croppedFaceSize.width, croppedFaceSize.height),
                              from: croppedFaceFrame,
                              operation: NSCompositingOperation.copy,
                              fraction: 1.0,
                              respectFlipped: true,
                              hints: [:])
        
        croppedSmiley.unlockFocus()
        
        let userFaceRect = CGRect(x: CGFloat(user.X!), y: CGFloat(user.Y!), width: CGFloat(spriteWidth), height: CGFloat(spriteHeight))
        
        croppedSmiley.draw(in: userFaceRect)
        //context!.draw(croppedSmiley, in: userFaceRect)
        
        let username: NSString = NSString(string: user.Username)
        
        // Username drop shadow
        let usernameShadow = NSShadow()
        //usernameShadow.shadowOffset = NSSize(width: 0, height: 0)
        usernameShadow.shadowBlurRadius = 3 // 2.5
        usernameShadow.shadowColor = NSColor.black
        
        let usernameTextAttributes: [String: Any] = [
            NSFontAttributeName: NSFont(name: "Helvetica Bold", size: 13.0)!,
            NSShadowAttributeName: usernameShadow,
            NSStrokeColorAttributeName: NSColor.black,
            NSStrokeWidthAttributeName: -1.25,
            NSForegroundColorAttributeName: MainView.RoomColors[Int(user.Color!)]!
            //NSKernAttributeName: 1.1,
            //"AppOuterStroke": 2.0
        ]
        
        let usernameWidth = ceil(Double(username.size(withAttributes: usernameTextAttributes).width))
        let usernameX = Double(user.X!) + 22 - usernameWidth/2
        let usernameY = Double(user.Y!) + 36
        
        cgContext!.setShouldSubpixelPositionFonts(true)
        cgContext!.setShouldSmoothFonts(true)
        cgContext!.setShouldAntialias(true)
        
        username.draw(at: NSPoint(x: CGFloat(Int(usernameX)) - 0.5, y: CGFloat(Int(usernameY)) + 0.5), withAttributes: usernameTextAttributes)
        
        cgContext!.setShouldSubpixelPositionFonts(true)
        cgContext!.setShouldSmoothFonts(true)
        cgContext!.setShouldAntialias(true)
        
        //cgContext!.restoreGState()
    }
    
    private func moveTo(point: NSPoint)
    {
        let actualPoint = self.convert(point, from: nil)
        if self.Client != nil && self.Client!.ConnectionState == .Connected {
            //self.RoomViewControllerDelegate!.MoveSelf(x: UInt16(actualPoint.x), y: UInt16(actualPoint.y))
            let x = actualPoint.x - 22
            let y = actualPoint.y - 22
            self.Client!.Move(x: 0 <= x ? UInt16(x) : 0, y: 0 <= y ? UInt16(y) : 0)
            //self.Client!.UserSelf.X = UInt16(actualPoint.x)
            //self.Client!.UserSelf.Y = UInt16(actualPoint.y)
        }
    }
    
    private func dragMove(point: NSPoint)
    {
        let actualPoint = self.convert(point, from: nil)
        let x = actualPoint.x - 22
        let y = actualPoint.y - 22
        self.Client!.User.X = 0 <= x ? UInt16(x) : 0
        self.Client!.User.Y = 0 <= y ? UInt16(y) : 0
    }
    /*
    func draw(bubble: PchatBubble, context: NSGraphicsContext?) {
        let messageAttributes: [String: Any] = [
            NSFontAttributeName: NSFont(name: "Helvetica", size: 13)!
        ]
        
        let message = bubble.message!
        let nsMessage = NSAttributedString(string: message.content, attributes: messageAttributes)
        
        //let messageSize = nsMessage.size()
        // display relative to user
        let messageSize = NSSize(width: CGFloat(300), height: CGFloat(400)) // calculate somehow...
        
        var x: CGFloat
        var y: CGFloat
        if message.user != nil {
            if 0 < Int(message.user!.X!) - Int(messageSize.width) - 10 { // && active Pmessage not already being displayed on left side
                // can display on left side
                x = CGFloat(Int(message.user!.X!) - Int(messageSize.width) - 10)
            }
            else {
                x = CGFloat(Int(message.user!.X!) + Int(messageSize.width) + 10)
            }
            
            y = CGFloat(message.user!.Y!) //if 0 < message.user!.Y!
        }
        
        let framePath = NSBezierPath(rect: messageFrame)
        
        var color: NSColor?
        if message.user != nil {
            color = MainView.RoomColors[Int(message.user!.Color!)]
        }
        else {
            color = NSColor.white
        }
        
        color!.set()
        framePath.stroke()
        framePath.fill()
 
        //nsMessage.draw(in: messageFrame)
        //NSStringDrawingOptions.

        nsMessage.draw(with: messageFrame, options: NSStringDrawingOptions.truncatesLastVisibleLine)ß
    } */
    
    func keyDown(event: NSEvent) {
        var isHandled = false
        let characters = event.charactersIgnoringModifiers
        
        // get the pressed key
        //characters = [event charactersIgnoringModifiers];
    
        // is the "r" key pressed?
        //if ([characters isEqual:@"r"]) {
        if characters == "r" {
            // Yes, it is
            isHandled = true
            
            // reset the rectangle
            //[self setItemPropertiesToDefault:self];
        }
        
        if (!isHandled) {
            super.keyDown(with: event)
        }
    }
    
    override func mouseDown(with event: NSEvent)
    {
        self.moveTo(point: event.locationInWindow)
    }
    
    override func rightMouseDragged(with event: NSEvent)
    {
        self.isDragging = true
        //self.needsDisplay = true
        self.dragMove(point: event.locationInWindow)
        
        super.rightMouseDragged(with: event)
    }
    
    override func rightMouseUp(with event: NSEvent)
    {
        if self.isDragging {
            self.moveTo(point: event.locationInWindow)
        }
        
        self.isDragging = false
        
        super.rightMouseUp(with: event)
    }
    
    /*
    func RemoveBackground() {
        Swift.print("Removing background from draw list.")
        self.BackgroundImage = nil
        self.needsDisplay = true
    }
    
    func Add(user: Puser) {
        Swift.print("Adding user \(user.Username) to draw list.")
        self.UserList!.append(user)
        self.needsDisplay = true
    }
    
    func Add(userSelf: Puser) {
        Swift.print("Adding user self \(userSelf.Username) to draw list.")
        self.UserSelf = userSelf
        self.UserList!.append(userSelf)
        self.needsDisplay = true
    }
    
    func RemoveAllUsers() {
        Swift.print("Removing all users from draw list.")
        self.UserList!.removeAll()
        self.needsDisplay = true
    }
    
    func Remove(userId: UInt32) {
        let user = Puser.User(with: userId, userList: self.UserList!)
        let index = self.UserList!.index(where: { (user) -> Bool in
            user.Id! == userId
        })
        self.UserList!.remove(at: index!)
        Swift.print("Removing user \(user!.Username) from draw list.")
        self.needsDisplay = true
    }
    
    func Move(userId: UInt32, x: UInt16, y: UInt16) {
        let user = Puser.User(with: userId, userList: self.UserList!)
        Swift.print("Move user \(user!.Username) to (\(x), \(y)).")
        user!.Y = y
        user!.X = x
        self.needsDisplay = true
    } */
}
