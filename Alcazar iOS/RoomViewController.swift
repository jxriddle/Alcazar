//
//  ViewController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import UIKit
import CoreData

class RoomViewController: UIViewController {
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextField!
    
    internal weak var pclient: Pclient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func connectToPalaceWith(pclient: Pclient!) {
        self.pclient = pclient
        pclient.username = "xyzzy iOS"
    }
}

