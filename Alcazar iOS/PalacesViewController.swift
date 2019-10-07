//
//  PalacesViewController.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import UIKit
import CoreData

public class PserverTableViewCell: UITableViewCell
{
    @IBOutlet weak var pserverImgView: UIImageView!
    @IBOutlet weak var pserverName: UILabel!
    @IBOutlet weak var pserverDescription: UILabel!
    
    var pserver: PserverNode! {
        didSet {
            self.updateUI()
        }
    }
    
    func updateUI()
    {
        pserverName.text = pserver.name
        pserverDescription.text = pserver.description
        pserverImgView.image = UIImage(named: "pserverThumbnail")
    }
}

public class PalacesViewController: UITableViewController
{
    internal var pserverListBook = [NSManagedObject]()
    internal var pserverListDir = [PserverNode]()
    let sectionTitle = ["Connections", "Bookmarks", "Directory"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    internal static let OK = 200
    internal static let URLPATH = "http://pchat.org/webservice/directory/get/"
    
    internal func fetchPserverListTopCompletion(data: Data?)
    {
        do {
            if let rootJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String, Any> {
                if let dirJson = rootJson["directory"] as? [Dictionary<String, Any>] {
                    for pserverNodeJson in dirJson {
                        self.pserverListDir.append(PserverNode(json: pserverNodeJson))
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch { //let error as Error {
            //print("Error getting json data: \(error.localizedDescription)")
            print("error getting top palace servers list")
        }
    }
    
    internal func fetchDataAt(url: String, completion: @escaping (Data) -> Void)
    {
        let urlrep = URL(string: url)
        let request = URLRequest(url: urlrep!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                completion(data!)
            }
        }
        //var connection = URLConnection(request: request, delegate: self, startImmediately: false)
        
        //connection.start()
        task.resume()
    }
    
    
    @IBAction func didCancelSettings(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func didSaveSettings(segue: UIStoryboardSegue) {
        let context = appDelegate.persistentContainer.viewContext
        œ
        context.insert(segue.)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addItem))
        self.fetchDataAt(url: PalacesViewController.URLPATH, completion: fetchPserverListTopCompletion)
    }
    
    //override func viewDidLoad() {
    //    super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addItem))
    //}
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //var palaceServerListItem = tableView.cellForRow(at: indexPath) as! PalaceServerListItem
        //palaceClient.serverNickname = palaceServerListItem.nickname
        //palaceClient.hostname = palaceServerListItem.hostname
        //palaceClient.port = palaceServerListItem.port
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let pclient = Pclient()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var pclientList = appDelegate.pclientList
        pclientList.append(pclient)
        
        if segue.identifier == "MySettingsSegue" {
            //let settingsViewController: SettingsViewController = segue.destination as! SettingsViewController
            //settings
        } else if segue.identifier == "RoomSegue" {
            let roomViewController: RoomViewController = segue.destination as! RoomViewController
            roomViewController.connectToPalaceWith(pclient: pclient)
        }
    }

    // CoreData addition
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.appDelegate.pclients.count
        }
        else if section == 1 {
            return self.pserverListBook.count
        }
        else if section == 2 {
            return self.pserverListDir.count
        }
        
        return 0
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: PserverTableViewCell?
        /*
        // Pull from CoreData
        if (indexPath.section == 0) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "PserverCell") as? PserverTableViewCell
            //cell.textLabel?.text = pserverBookmarkList[indexPath.row]
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "PserverCell") as? PserverTableViewCell
            }
        }
        // Pull from Json
        else if (indexPath.section == 1) {
 */
            cell = self.tableView.dequeueReusableCell(withIdentifier: "PserverCell")! as? PserverTableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "PserverCell") as? PserverTableViewCell
            }
            
            cell?.pserverName?.text = self.pserverListTop[indexPath.row].name
            cell?.pserverDescription?.text = self.pserverListTop[indexPath.row].description
        //}
        
        return cell!
    }
    
    // CoreData addition
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.pserverListBook.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitle.count
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.sectionTitle[section]
    }
    
    func addItem() {
        let alertController = UIAlertController(title: "Palace Server", message: "Server", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Save", style: .default, handler: ({
            (_) in
            if let field = (alertController.textFields![0]) as UITextField? {
                self.saveItem(itemToSave: field.text!)
                self.tableView.reloadData()
            }
        }))
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addTextField(configurationHandler: {
            (textFieldAddress) in
            textFieldAddress.placeholder = "Server (e.g. fabrik.epalaces.net)"
        })
        
        alertController.addTextField(configurationHandler: {
            (textFieldPort) in
            textFieldPort.placeholder = "Port (e.g. 9998)"
        })
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func saveItem(itemToSave: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _ = appDelegate.persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Pserver", in: moContext)
        //let pserverNode = Pserver(context: NSManagedObject(entity: entity!, insertInto: moContext) as! PserverNode)
        //pserverNode.setValue(itemToSave, forKey: "Pserver")
        //do {
        //    try moContext.save()
        //    pserverBookmarkList.append(pserverNode)
        //}
        //catch {
        //    print("error")
        //}
    }
}

