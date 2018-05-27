//
//  WorkingModel.swift
//  Aqua
//
//  Created by PHUCLONG on 1/22/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import Foundation

struct WorkingModel {
    var id: Int = 0
    var workingDate: String = ""
    var working: String = ""
    var workingOld: String = ""
    var note: String = ""
    var shopcode: String = ""
    var shopName: String = ""
    var employeeName: String = ""
    var employeeCode: String = ""
    var confirm: Int = 0
    init() {
        
    }
}
struct ShiftModel{
    var shift = ""
    var foreColor = ""
    var working = ""
    var note = ""
    var status: Int?
}
