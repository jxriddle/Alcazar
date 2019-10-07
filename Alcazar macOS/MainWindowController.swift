//
//  WindowController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/29/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate, WindowControllerDelegate {
    @IBOutlet weak var palaceSearchField: PalaceSearchField!
    
    @IBAction func palaceSearchFieldAction(_ sender: Any) {
        //let mainViewController = self.presenting as! MainViewController
        //mainViewController.setPalaceHostname(hostnameTextField.stringValue)
        //if delegate != nil {
        let mainVc = self.contentViewController! as! MainViewController
        //let mainViewController = self.presenting as! MainViewController
        //mainViewController.setPalaceHostname(hostnameTextField.stringValue)
        //if delegate != nil {
        mainVc.Client!.ConnectTo(palaceUrl: palaceSearchField.stringValue)
    }
    
    override func windowDidLoad() {
        self.window?.titleVisibility = .hidden
        self.window?.delegate = self
        
        let mainVc = self.contentViewController! as! MainViewController
        mainVc.WindowControllerDelegate = self
        
        // TODO show log window at startup if necessary.
        // TODO also, will need to make log window a toggle at some point.
        //let storyboard = NSStoryboard(name: "Main", bundle: nil)
        //let logWc = storyboard!.instantiateController(withIdentifier: "logWindowController") as! NSWindowController
        //mainVc.Client!.Logger.Add(receiver: logVc.logNotifyCallback, minLogLevel: .Debug, maxLogLevel: .Whitespace)
        //logWc.showWindow(self)
        
        //let logSegue = NSStoryboardSegue(identifier: "logWindowSegue", source: self, destination: self)
        //self.prepare(for: logSegue, sender: self)
        self.performSegue(withIdentifier: "logWindowSegue", sender: self)
    }
    
    func windowWillClose(_ notification: Notification) {
        //NSApp.terminate(self)
        let vc = self.contentViewController! as! MainViewController
        vc.Client!.Disconnect()
        
        NSApplication.shared().terminate(self)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "logWindowSegue" {
            let mainVc = self.contentViewController! as! MainViewController
            let wc = segue.destinationController as! NSWindowController
            let logVc = wc.contentViewController! as! LogViewController
            logVc.clientDelegate = mainVc
            mainVc.Client!.Logger.Add(receiver: logVc.logNotifyCallback, minLogLevel: .Debug, maxLogLevel: .Whitespace)
            // also update the textfield from store
            //vc.logTextField
        }
        else if segue.identifier == "userListViewSegue" {
            //print("userListViewSegue")
            // based on currently active view
            let mainVc = self.contentViewController! as! MainViewController
            let destVc = segue.destinationController as! UserListViewController
            destVc.view.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
            destVc.tableView.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
            destVc.Client = mainVc.Client!
            //mainVc.Client!.RoomList
        }
        else if segue.identifier == "roomListViewSegue" {
            //print("roomListViewSegue")
            let mainVc = self.contentViewController! as! MainViewController
            let destVc = segue.destinationController as! RoomListViewController
            destVc.view.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
            destVc.tableView.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
            destVc.Client = mainVc.Client!
            // based on currently active view
            
        }
    }
    
    func ResizeWindow(width: CGFloat, height: CGFloat) {
        let currentFrame = self.window!.frame
        let newFrame = NSRect(x: currentFrame.origin.x, y: currentFrame.origin.y, width: width, height: height + self.window!.titlebarHeight)
        self.window!.setFrame(newFrame, display: true)
    }
}
