//
//  File.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-09.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit;
import SWXMLHash

class Spell: NSObject, NSCoding {
    
    //MARK: Properties
    struct PropertyKey{
        static let infoFields = "infoFields"
        static let name = "name"
        static let level = "level"
        static let _class = "_class"
        static let desc = "desc"
        static let table = "table"
    }
    
    var infoFields: Dictionary<String, Any>?
    var name: String = ""
    var level: Int = 0
    var _class = [String]()
    var desc = [[String]]()
    var table: [[[String]]]?
    var jsonRepresentation : String{
        var dict = [
            "name" : name,
            "level" : level,
            "classes" : _class,
            "desc" : desc,
            "table" : table as Any
        ] as [String : Any]

        dict.append(with: infoFields!)
        
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data:data, encoding:.utf8)!
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("spells")
    
    init(dictionary: [String: Any]){
        var dict = dictionary
        self.name = dict["name"] as! String
        dict.removeValue(forKey: "name")
        self.level = dict["level"] as! Int
        dict.removeValue(forKey: "level")
        self._class = dict["classes"] as! [String]
        dict.removeValue(forKey: "class")
        self.desc = dict["desc"] as! [[String]]
        dict.removeValue(forKey: "desc")
        self.table = dict["table"] as? [[[String]]]
        dict.removeValue(forKey: "table")
        
        infoFields = dict
    }
    
    init(name: String, level: Int, _class: [String], desc: [[String]], infoFields: Dictionary<String, Any>?, table: [[[String]]]?){
        self.name = name
        self.level = level
        self._class = _class
        self.desc = desc
        self.infoFields = infoFields
        self.table = table
    }
    
    init(data: XMLIndexer){
        self.name = data["name"].element!.text
        self.level = Int(data["level"].element!.text)!
        
        self._class = (data["classes"].element!.text).components(separatedBy: ", ")
        
        self.desc.append([String]())
        var currentText = ""
        for text in data["text"].all{
            currentText += text.element!.text
            if currentText == "" {
                self.desc[0].append(currentText)
                currentText = ""
            } else{
                currentText += "\n"
            }
            
        }
        if currentText != "" {
            self.desc[0].append(currentText)
        }
        
        let nonInfoFields = ["name", "level", "classes", "text"]
        let infoData = data.children.filter{!nonInfoFields.contains($0.element!.name)}
        
        if infoData != nil{
            
            infoFields = [String: [Any]]()
            
            for key in infoData{
                infoFields![key.element!.name] = key.element!.text
            }
        }
        
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder){
        aCoder.encode(infoFields, forKey: PropertyKey.infoFields)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(level, forKey: PropertyKey.level)
        aCoder.encode(_class, forKey: PropertyKey._class)
        aCoder.encode(desc, forKey: PropertyKey.desc)
        aCoder.encode(table, forKey: PropertyKey.table)
    }
    
    required convenience init?(coder aDecoder: NSCoder){
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else{
            return nil
        }
        guard let level = aDecoder.decodeInteger(forKey: PropertyKey.level) as? Int else{
            return nil
        }
        guard let _class = aDecoder.decodeObject(forKey: PropertyKey._class) as? [String] else{
            return nil
        }
        guard let desc = aDecoder.decodeObject(forKey: PropertyKey.desc) as? [[String]] else{
            return nil
        }
        let infoFields = aDecoder.decodeObject(forKey: PropertyKey.infoFields) as? Dictionary<String, Any>
        let table = aDecoder.decodeObject(forKey: PropertyKey.table) as? [[[String]]]
        
        // Must call designated initializer
        self.init(name: name, level: level, _class: _class, desc: desc, infoFields: infoFields, table: table)
    }
    
}

extension Dictionary {
    /// Merge and return a new dictionary
    func merge(with: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var copy = self
        for (k, v) in with {
            // If a key is already present it will be overritten
            copy[k] = v
        }
        return copy
    }
    
    /// Merge in-place
    mutating func append(with: Dictionary<Key,Value>) {
        for (k, v) in with {
            // If a key is already present it will be overritten
            self[k] = v
        }
    }
}
