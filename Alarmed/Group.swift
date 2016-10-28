//
//  Group.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

class Group: NSObject {
    
    var id: String
    var name: String
    var playSound: Bool
    var enabled: Bool
    var alarms: [Alarm]
    
    init(name: String, playSound: Bool, enabled: Bool, alarms: [Alarm]) {
        
        self.id = UUID().uuidString
        self.name = name
        self.playSound = playSound
        self.enabled = enabled
        self.alarms = alarms
    }

}
