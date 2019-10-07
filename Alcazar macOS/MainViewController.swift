//
//  ViewController.swift
//  Alcazar macOS
//
//  Created by Jesse Riddle on 3/27/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

protocol WindowControllerDelegate {
    func ResizeWindow(width: CGFloat, height: CGFloat)
}

class MainViewController: NSViewController, RoomViewControllerDelegate, PclientDelegate {
    
    @IBOutlet weak var chatTextField: NSTextField!
    public var Client: Pclient?
    
    var WindowControllerDelegate: WindowControllerDelegate?
    
    //@IBAction override func unwindToMain(segue: StoryboardSegue) {
    //}
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.Client = Pclient()
        self.Client!.RoomViewControllerDelegate = self
        
        // add client reference
        let mainView = self.view as! MainView
        mainView.Client = self.Client
        
        // add callback for chat messages
        self.Client!.Logger.Add(receiver: self.messageNotifyCallback, minLogLevel: .System, maxLogLevel: .Say)
        
        mainView.ChatQueue = AppQueue<Pmessage>()
    }
    
    override var representedObject: Any?
        {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        /* set log contents either here or in windowDidLoad */
        //self.view.setFirstResponder(chatTextField!)
        //let view = self.view as! MainView
        //view.RoomViewControllerDelegate = self
    }
    
    // RoomViewControllerDelegate
    func UpdateBackground() {
        /*
        self.Client!.Logger.Log(debug: "Setting background to \(self.Client!.Room.BackgroundImage.Name!)")
        
        let nsImage = NSImage(data: self.Client!.Room.BackgroundImage.ImageData!)
        
        if nsImage != nil {
            nsImage!.draw(in: self.view.bounds)
        }
        */
/*
        let nsImage = NSImage(data: image.ImageData!)
        let nsImageReps = nsImage!.representations
        let imageSize = nsImageReps.reduce(CGSize.zero, { (size: CGSize, rep: NSImageRep) -> CGSize in
            CGSize(width: max(size.width, CGFloat(rep.pixelsWide)), height: max(size.height, CGFloat(rep.pixelsHigh)))
        })
        
        let frameSize = NSSize(width: imageSize.width, height: imageSize.height)
        
        self.Client!.Logger.Log(debug: "Resizing to accomodate background image of size \(Int(imageSize.width))x\(Int(imageSize.height)).")
        
        let view = self.view as! MainView
        view.setFrameSize(frameSize)
        
        self.WindowControllerDelegate!.ResizeWindow(width: imageSize.width, height: imageSize.height)
        //view.layer!.contents = nsImage
        
        image.X = 0
        image.Y = 0
        image.Width = Int(imageSize.width)
        image.Height = Int(imageSize.height)
        */
        //view.BackgroundImage = image // Pimage
        
        self.view.needsDisplay = true
    }
    
    func UpdateUsers() {
        self.view.needsDisplay = true
    }
    
    /*
    func Add(user: Puser) {
        let view = self.view as! MainView
        view.Add(user: user)
    }
    
    func Add(userSelf: Puser) {
        let view = self.view as! MainView
        view.Add(userSelf: userSelf)
    }
    
    func RemoveAllUsers() {
        let view = self.view as! MainView
        view.RemoveAllUsers()
    }
    
    func Remove(userId: UInt32) {
        // TODO stub
    }
    
    func Move(userId: UInt32, x: UInt16, y: UInt16) {
        let view = self.view as! MainView
        view.Move(userId: userId, x: x, y: y)
    } */
    
    func MoveSelf(x: UInt16, y: UInt16) {
        self.Client!.Move(x: x, y: y)
    }
    
    func SetBackground(image: Pimage) {
        self.Client!.Room!.BackgroundImage = image
        
        let nsImage = NSImage(data: image.ImageData!)
        let nsImageReps = nsImage!.representations
        let imageSize = nsImageReps.reduce(CGSize.zero, { (size: CGSize, rep: NSImageRep) -> CGSize in
            CGSize(width: max(size.width, CGFloat(rep.pixelsWide)), height: max(size.height, CGFloat(rep.pixelsHigh)))
        })
        
        let frameSize = NSSize(width: imageSize.width, height: imageSize.height)
        
        self.Client!.Logger.Log(debug: "Resizing to accomodate background image of size \(Int(imageSize.width))x\(Int(imageSize.height)).")
        
        let view = self.view as! MainView
        view.setFrameSize(frameSize)
        
        self.WindowControllerDelegate!.ResizeWindow(width: imageSize.width, height: imageSize.height)
        //view.layer!.contents = nsImage
        
        self.Client!.Room!.BackgroundImage.X = 0
        self.Client!.Room!.BackgroundImage.Y = 0
        self.Client!.Room!.BackgroundImage.Width = UInt16(Int(imageSize.width))
        self.Client!.Room!.BackgroundImage.Height = UInt16(Int(imageSize.height))
        
        self.view.needsDisplay = true
        //return (Int(imageSize.width), Int(imageSize.height))
    }
    
    func messageTimerNotifyCallback(timer: Timer)
    {
        //let view = sender as! NSView
        
        // find subview
        //view.superview!.subviews.remove(at: 0)
    }
    
    func messageNotifyCallback(message: Pmessage)
    {
        // enqueue chat message
        //let view = self.view as! MainView
        //view.ChatQueue!.enqueue(message)
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        let messageSize = NSSize(width: 150, height: 250)
        
        if message.user != nil {
            if 0 < Int(message.user!.X!) - Int(messageSize.width) - 22 { // && active Pmessage not already being displayed on left side
                // can display on left side
                x = CGFloat(Int(message.user!.X!) - Int(messageSize.width) - 22)
            }
            else {
                x = CGFloat(Int(message.user!.X!) + Int(messageSize.width) + 22)
            }
            
            y = CGFloat(message.user!.Y!) - 0.5 * messageSize.height - 22 //if 0 < message.user!.Y!
        }
        
        //let timer = Timer(timeInterval: 5, target: self, selector: messageTimerNotifyCallback, userInfo: nil, repeats: false)
        let timer = Timer(timeInterval: 5, repeats: false, block: messageTimerNotifyCallback)
        
        let chatBubbleView = ChatBubbleView(frame: CGRect(x: x, y: y, width: CGFloat(150), height: CGFloat(250)), timer: timer, message: message)
        
        //self.chatBubbleViews.append(chatBubbleView)
        
        //let timer = Timer
        
        //self.view.subviews.insert(
        //    ChatBubbleView(
        //    frame: CGRect(x: x, y: y, width: CGFloat(150), height: CGFloat(250)),
        //    expiresIn: 5,
        //    message: message
        //), at: 0)
        
        self.view.needsDisplay = true
    }
}

