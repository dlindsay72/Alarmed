//
//  Helper.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-31.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import Foundation

struct Helper {
    
    static func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    static func save() {
        NotificationCenter.default.post(name: Notification.Name("save"), object: nil)
    }
}
