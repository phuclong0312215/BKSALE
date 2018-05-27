//
//  Preferences.swift
//  Aqua
//
//  Created by PHUCLONG on 1/22/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import Foundation
import UIKit
class Preferences {
    static var PARAMATER = UserDefaults()
    init() {
        
    }
    static func put(key: String,value: String) {
        
        PARAMATER.setValue(value, forKeyPath: key)
        
    }
    static func get(key: String) -> String {
        let value = (PARAMATER.object(forKey: key) as? String)!
        return value
    }
    
    
}

