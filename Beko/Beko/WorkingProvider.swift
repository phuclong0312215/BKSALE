//
//  WorkingProvider.swift
//  Aqua
//
//  Created by PHUCLONG on 1/22/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class WorkingProvider {
    var http = Http()
    var URL_WORKING = "http://beko.spiral.com.vn:1000/Working.ashx"
    init() {
        
    }
    func getShift(_ access_token: String,function: String,workingDate: String,shopCode: String,empCode: String,completionHandler: @escaping([ShiftModel]?,String?) -> ()){
        let paramaters: Parameters = ["WorkingDate": workingDate,
                                      "ShopCode": shopCode,
                                      "EmployeeCode": empCode,
                                      "FUNCTION": function,
                                      "access_token": access_token,]
        requestShift(paramaters,completionHandler: completionHandler)
    }
    
    func getList(_ access_token: String,function: String,model: WorkingModel,completionHandler: @escaping([WorkingModel]?,String?) -> ()){
        var paramaters = getParamater(access_token,function: function,model: model)
        if function == "GETLIST"{
            paramaters = ["FUNCTION": function,
                          "ShopCode": model.shopcode,
                          "access_token": access_token]
        }
        requestWorking(paramaters, function: function, completionHandler: completionHandler)
    }
    func getEmployeeShop(_ access_token: String,function: String,model: WorkingModel,completionHandler: @escaping([WorkingModel]?,String?) -> ()){
        let paramaters: Parameters = ["FUNCTION": function,
                                      "access_token": access_token,]
        requestEmployee(paramaters, completionHandler: completionHandler)
    }
    
    func requestEmployee(_ parameters: Parameters,completionHandler: @escaping ([WorkingModel]?, String?) -> ()){
        http.performRequest(.post, requestURL: URL_WORKING, params: parameters as [String : AnyObject]) { (responseJSON) in
            if(responseJSON != nil){
                
                let swiftJSON = JSON(responseJSON)
                let arr = swiftJSON["Content"].arrayValue
                let shifts = self.getListWorkings(arr)
                completionHandler(shifts, nil)
            }
            else{
                completionHandler(nil,"Không có data.")
            }
        }
    }

    func confirmWorking(_ access_token: String,function: String,workingDate: String,shopCode: String,empCode: String,working: String,completionHandler: @escaping(Int?) -> ()){
       
        var paramaters = ["FUNCTION": function,
                       "ShopCode": shopCode,
                       "EmployeeCode": empCode,
                       "WorkingDate": workingDate,
                       "Working": working,
                      "access_token": access_token]
        
        requestConfirmWorking(paramaters,completionHandler: completionHandler)

    }
    func getParamater(_ access_token: String,function: String,model: WorkingModel) -> Parameters{
        let paramaters: Parameters = ["Id": model.id,
                                      "Working": model.working,
                                      "AuditDate": model.workingDate,
                                    "EmployeeCode": model.employeeCode,
                                      "ShopCode": model.shopcode,
                                      "Comment": model.note,
                                     
                                      "access_token": access_token,
                                      "FUNCTION": function]
        return paramaters
    }
    func requestConfirmWorking(_ parameters: Parameters,completionHandler: @escaping (Int?) -> ()){
        http.performRequest(.post, requestURL: URL_WORKING, params: parameters as [String : AnyObject]) { (responseJSON) in
            if(responseJSON != nil){
                 completionHandler(1)
            }
            else{
                completionHandler(0)
            }
        }
    }

    func requestShift(_ parameters: Parameters,completionHandler: @escaping ([ShiftModel]?, String?) -> ()){
        http.performRequest(.post, requestURL: URL_WORKING, params: parameters as [String : AnyObject]) { (responseJSON) in
            if(responseJSON != nil){
                
                let swiftJSON = JSON(responseJSON)
                let arr = swiftJSON["Content"].arrayValue
                let shifts = self.getListShifts(arr)
                completionHandler(shifts, nil)
            }
            else{
                completionHandler(nil,"Không có data.")
            }
        }
    }
    func getListShifts(_ arrJSON: [JSON]) -> [ShiftModel] {
        var lstShifts: [ShiftModel] = []
        if arrJSON != nil && arrJSON.count > 0 {
            for item in arrJSON {
                var model = ShiftModel()
                model.shift = item["Shift"].stringValue
                model.foreColor = item["ForeColor"].stringValue
                model.note = item["Note"].stringValue
                if let status = item["Status"].intValue as? Int {
                    model.status = status
                }
               
               // print(model)
                lstShifts.append(model)
            }
            
        }
        return lstShifts
        
    }
    func getListWorkings(_ arrJSON: [JSON]) -> [WorkingModel] {
        var lstWorkings: [WorkingModel] = []
        if arrJSON != nil && arrJSON.count > 0 {
            for item in arrJSON {
                var model = WorkingModel()
                model.shopcode = item["ShopCode"].stringValue
                model.workingDate = item["AuditDate"].stringValue
                model.workingOld = item["WorkingOld"].stringValue
                model.working = item["Working"].stringValue
                model.employeeCode = item["EmployeeCode"].stringValue
                model.employeeName = item["EmployeeName"].stringValue
                model.shopName = item["ShopName"].stringValue
                model.note = item["Comment"].stringValue
//                if let confirm = item["Confirm"].intValue as? Int {
//                    model.confirm = confirm
//                }

                if let id = item["id"].intValue as? Int {
                    model.id = id
                }
                
               // print(model)
                lstWorkings.append(model)
            }
            
        }
        return lstWorkings
        
    }

    func requestWorking(_ parameters: Parameters,function: String,completionHandler: @escaping ([WorkingModel]?, String?) -> ()){
        http.performRequest(.post, requestURL: URL_WORKING, params: parameters as [String : AnyObject]) { (responseJSON) in
            if(responseJSON != nil){
                if function == "GETLIST"{
                    let swiftJSON = JSON(responseJSON)
                    let arr = swiftJSON["Content"].arrayValue
                    let workings = self.getListWorkings(arr)
                    completionHandler(workings, nil)
                }
                else{
                    completionHandler([WorkingModel](), nil)
                }
            }
            else{
                completionHandler(nil,"Không có cửa hang.")
            }
        }
    }
}
