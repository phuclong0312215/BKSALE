//
//  ReportController.swift
//  Beko
//
//  Created by PHUCLONG on 12/12/17.
//  Copyright © 2017 PHUCLONG. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class ReportProvider{
    var http = Http()
    var URL_GET_DATA="http://beko.spiral.com.vn:1000/GetData.ashx"
    init() {
        
    }
    func getList(_ access_token: String,shopCode: String,completionHandler: @escaping([ReportModel]?,String?) -> ()){
        let parameters: Parameters = ["ShopCode": shopCode,"FUNCTION": "REPORT","Month" : Date().month(),"Year": Date().year(),"WorkDate": Date().toShortTimeString(),"access_token": access_token]
        requestList(parameters, completionHandler: completionHandler)
    }
    func requestList(_ parameters: Parameters,completionHandler: @escaping ([ReportModel]?, String?) -> ()){
        http.performRequest(.post, requestURL: URL_GET_DATA, params: parameters as [String : AnyObject]) { (responseJSON) in
            if(responseJSON != nil){
                let swiftJSON = JSON(responseJSON)
                let arr = swiftJSON["Content"].arrayValue
                let reports = self.getListResult(arr)
                completionHandler(reports, nil)
            }
            else{
                completionHandler(nil,"Không có data.")
            }
        }
    }
    func getListResult(_ arrJSON: [JSON]) -> [ReportModel] {
        var lstReports: [ReportModel] = []
        if arrJSON != nil && arrJSON.count > 0 {
            for item in arrJSON {
                let model = ReportModel()
                model.pivot = item["pivotColumn"].stringValue
                model.value = item["ColumnValues"].stringValue
                lstReports.append(model)
            }
            
        }
        return lstReports
        
    }

    
}
