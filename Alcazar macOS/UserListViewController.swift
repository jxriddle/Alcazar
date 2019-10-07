//
//  UserListViewController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/29/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

extension UserListViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.Client?.Server?.UserList.count ?? 0
    }
}

extension UserListViewController: NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        
        //print("Determining cell view...")
        
        var text: String = ""
        var cellIdentifier = ""
        
        let user = self.Client!.Server!.UserList[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = user.Username
            cellIdentifier = "UsernameCell"
        }
        else if tableColumn == tableView.tableColumns[1] {
            let room = Proom.Room(with: UInt32(user.RoomId!), roomList: self.Client!.Server!.RoomList)
            
            let roomName = room != nil ? room!.Name! : "nil"
            text = roomName
            cellIdentifier = "RoomNameCell"
        }
        
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            //print("Cell view determined to contain \(text)")
            cell.appearance = NSAppearance(appearanceNamed: NSAppearanceNameVibrantLight, bundle: nil)
            return cell
        }
        else {
            print("Failed to determine cell view for column \(tableColumn?.identifier ?? "<unknown>")")
        }
        
        return nil
    }
    
    //func tableViewSelectionDidChange(_ notification: Notification) {
    // TODO stub
    //}
}

extension UserListViewController: ServerListDelegate
{
    func Update()
    {
        self.tableView.reloadData()
        self.tableView.tableColumns[0].title = String("\(self.tableView.numberOfRows) Users")
    }
}

class UserListViewController : NSViewController
{
    public var Client: Pclient?
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.target = self
        self.tableView.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    override func viewDidAppear()
    {
        self.tableView.reloadData()
        self.tableView.tableColumns[0].title = String("\(self.tableView.numberOfRows) Users")
        self.Client!.RequestServerUserList()
    }
    
    func tableViewDoubleClick(_ sender: Any)
    {
        if self.tableView.selectedRow < 0 || self.Client!.Server!.UserList.count <= self.tableView.selectedRow {
            return
        }
        
        let user = self.Client!.Server!.UserList[self.tableView.selectedRow]
        if user.RoomId != nil {
            self.Client!.GotoRoom(id: user.RoomId!)
        }
        
        self.dismiss(self)
    }
}
