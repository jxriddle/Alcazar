//
//  LogViewController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/29/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

class LogViewController: NSViewController
{
    @IBOutlet weak var logTextView: NSTextView!
    @IBOutlet weak var logTextField: NSTextField!
    
    public static let LogColors: [Int: NSColor] = [
        0: NSColor.red,
        1: NSColor.red.blended(withFraction: 0.5, of: NSColor.orange)!,
        2: NSColor.orange,
        3: NSColor.yellow.blended(withFraction: 0.5, of: NSColor.black)!,
        4: NSColor.yellow.blended(withFraction: 0.3, of: NSColor.green)!.blended(withFraction: 0.5, of: NSColor.black)!,
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
    
    var clientDelegate: PclientDelegate? // LogViewControllerDelegate?
    var textShadow: NSShadow?
    var usernameFont: NSFont?
    var whisperUsernameFont: NSFont?
    var textFont: NSFont?
    var whisperTextFont: NSFont?
    
    override func viewDidLoad() {
        self.logTextView.isEditable = false
        //view.backgroundColor = UIColor.clearColor()
        //view.opaque = false
        self.textShadow = NSShadow()
        //self.textShadow?.shadowOffset = NSSize(width: -1, height: -1)
        self.textShadow!.shadowBlurRadius = 1.5
        self.textShadow!.shadowColor = NSColor.black
        
        self.usernameFont = NSFont(name: "Helvetica Neue", size: 12)!
        self.textFont = NSFont(name: "Helvetica Neue", size: 12)!
        
        self.whisperUsernameFont = NSFont(name: "Helvetica Neue Italic", size: 12)!
        self.whisperTextFont = NSFont(name: "Helvetica Neue Italic", size: 12)!
    }
    
    @IBAction func logTextFieldAction(_ sender: Any)
    {
        //let appDelegate = NSApplication.shared().delegate as! AppDelegate
        
        if self.clientDelegate?.Client == nil { return }
        
        if clientDelegate!.Client!.SelectedUser == nil {
            //delegate!.log(content: self.logTextField.stringValue, type: .say)
            clientDelegate!.Client!.RoomChat(message: self.logTextField.stringValue)
            //delegate!.Client!.Logger.Log(say: self.logTextField.stringValue)
        }
        else { // whisper to who?
            //delegate!.log(content: self.logTextField.stringValue, type: .whisper)
            //delegate!.Client!.Logger.Log(whisper: self.logTextField.stringValue)
        }
        
        logTextField!.stringValue = ""
    }
    
    func logNotifyCallback(message: Pmessage)
    {
        //Swift.print(message.content)
        //self.logTextView.isEditable = true
        //self.logTextView.insertText(message.content, replacementRange: NSRange(location: self.logTextView.textStorage!.length, length: 0))
        let user = message.user
        let logMessage: NSAttributedString
        if user == nil {
            logMessage = NSAttributedString(string: "\(message.content)\n")
        }
        else if message.type == .Whisper {
            let logNameAttributes: [String: Any] = [
                NSFontAttributeName: self.whisperUsernameFont! // NSFont(name: "Helvetica Bold", size: 13.0)!
                //NSShadowAttributeName: self.textShadow!
            ]
            
            let logMessageAttributes: [String: Any] = [
                NSForegroundColorAttributeName: LogViewController.LogColors[Int(user!.Color!)]!,
                //NSShadowAttributeName: self.textShadow!,
                NSStrokeWidthAttributeName: -2,
                NSStrokeColorAttributeName: NSColor.brown,
                NSFontAttributeName: self.whisperTextFont!
            ]
            
            logMessage = NSMutableAttributedString(string: "Whisper from \(user!.Username): ", attributes: logNameAttributes) + NSMutableAttributedString(string: message.content, attributes: logMessageAttributes) + NSMutableAttributedString(string: "\n")
        }
        else {
            let logNameAttributes: [String: Any] = [
                NSFontAttributeName: self.usernameFont! // NSFont(name: "Helvetica Bold", size: 13.0)!
                //NSShadowAttributeName: self.textShadow!
            ]
            
            let logMessageAttributes: [String: Any] = [
                NSForegroundColorAttributeName: LogViewController.LogColors[Int(user!.Color!)]!,
                //NSShadowAttributeName: self.textShadow!,
                NSStrokeWidthAttributeName: -2,
                NSStrokeColorAttributeName: NSColor.brown,
                NSFontAttributeName: self.textFont!
            ]
            
            logMessage = NSMutableAttributedString(string: "\(user!.Username): ", attributes: logNameAttributes) + NSMutableAttributedString(string: message.content, attributes: logMessageAttributes) + NSMutableAttributedString(string: "\n")
        }
        
        self.logTextView.textStorage!.append(logMessage)
        //self.logTextView.insertNewline(self)
        self.logTextView.scrollRangeToVisible(NSMakeRange(self.logTextView.string!.length, 0))
        //self.logTextView.isEditable = false
    }
}
