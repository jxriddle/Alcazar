//
//  PserverNode.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/7/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public class Pserver
{
    public var Name: String?
    public var Population: Int?
    public var Address: String?
    public var Language: String?
    public var Category: String?
    public var Picture: String?
    public var Description: String?
    public var Website: String?
    public var Endianness: EndianType = .Unknown
    public var UserList: [Puser] = []
    public var RoomList: [Proom] = []
    
    init() {
    }
    
    init(Name: String?, Population: Int?, Address: String?, Language: String?, Category: String?, Picture: String?, Description: String?, Website: String?) {
        self.Name = Name
        self.Population = Population
        self.Address = Address
        self.Language = Language
        self.Category = Category
        self.Picture = Picture
        self.Description = Description
        self.Website = Website
    }
    
    convenience init(json: Dictionary<String, Any>) {
        let rawName = json["name"] as? String
        let rawPopulation = json["population"] as? String
        let rawAddress = json["address"] as? String
        let rawLanguage = json["language"] as? String
        let rawCategory = json["category"] as? String
        let rawPicture = json["picture"] as? String
        let rawDescription = json["description"] as? String
        let rawWebsite = json["website"] as? String
        
        self.init(Name: rawName, Population: Int(rawPopulation!), Address: rawAddress, Language: rawLanguage, Category: rawCategory, Picture: rawPicture, Description: rawDescription, Website: rawWebsite)
    }
}
