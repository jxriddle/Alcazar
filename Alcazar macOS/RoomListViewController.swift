//
//  RoomListViewController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/29/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Cocoa

extension RoomListViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.Client?.Server?.RoomList.count ?? 0
    }
}

extension RoomListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        
        //print("Determining cell view...")
        
        var text: String = ""
        var cellIdentifier = ""
        
        let room = self.Client!.Server!.RoomList[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = room.Name!
            cellIdentifier = "RoomNameCell"
        }
        else if tableColumn == tableView.tableColumns[1] {
            text = String(room.UserCount ?? 99)
            cellIdentifier = "RoomUserCountCell"
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

extension RoomListViewController: ServerListDelegate
{
    func Update()
    {
        self.tableView.reloadData()
        self.tableView.tableColumns[0].title = String("\(self.tableView.numberOfRows) Rooms")
        //self.tableView.headerView.needsDisplay = true
    }
}

class RoomListViewController : NSViewController
{
    
    @IBOutlet weak var tableView: NSTableView!
    public var Client: Pclient?
    
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
        self.tableView.tableColumns[0].title = String("\(self.tableView.numberOfRows) Rooms")
        self.Client!.RequestServerRoomList()
    }
    
    func tableViewDoubleClick(_ sender: Any)
    {
        if self.tableView.selectedRow < 0 || self.Client!.Server!.RoomList.count <= self.tableView.selectedRow {
            return
        }
        
        let room = self.Client!.Server!.RoomList[self.tableView.selectedRow]
        if room.Id != nil {
            self.Client!.GotoRoom(id: UInt16(room.Id!))
        }
        
        self.dismiss(self)
    }
}
