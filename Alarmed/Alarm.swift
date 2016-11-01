//
//  Alarm.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

class Alarm: NSObject, NSCoding {
    
    var id: String
    var name: String
    var caption: String
    var time: Date
    var image: String
    
    required init?(coder aDecoder: NSCoder) {
        
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.caption = aDecoder.decodeObject(forKey: "caption") as! String
        self.time = aDecoder.decodeObject(forKey: "time") as! Date
        self.image = aDecoder.decodeObject(forKey: "image") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.caption, forKey: "caption")
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.image, forKey: "image")
    }
    
    init(name: String, caption: String, time: Date, image: String) {
        
        self.id = UUID().uuidString
        self.name = name
        self.caption = caption
        self.time = time
        self.image = image
    }

}
