//
//  WorkResultController.swift
//  Panasonic
//
//  Created by PHUCLONG on 10/3/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class WorkResultController {

    var connect:CConnect=CConnect(db: "beko",type: "sqlite")
    
    init(){
        
    }
    
    func insert(_ model:WorkResultModel) -> WorkResultModel{
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "INSERT INTO WorkResults(WorkDate,Locked,Uploaded,ShopCode,WorkTime) VALUES (" + String(model.WorkDate) + "," + String(model.Locked) + "," + String(model.Uploaded) + ",'" + model.ShopCode + "','" + model.WorkTime + "')"
        connect.Query(sql, database: database)
        let info = getWorkResultCurrent(model.ShopCode, workDate: model.WorkDate)
        
        return info!
        
    }
    
    func getByShop(_ shopCode: String) -> [WorkResultModel]? {
        
        let sql = "select ShopCode,WorkTime,WorkDate,Locked,Uploaded from WorkResults where ShopCode ='" + shopCode + "'"
        var arr: [WorkResultModel]?
        arr = getWorkResults(sql);
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
        
    }
    func getWorkResultCurrent(_ shopCode: String,workDate: Int) -> WorkResultModel? {
        
        let sql = "select ShopCode,WorkTime,WorkDate,Locked,Uploaded,_id from WorkResults where ShopCode ='" + shopCode + "' and WorkDate = " + String(workDate)
        var arr: [WorkResultModel]?
        arr = getWorkResults(sql);
        if(arr != nil && arr!.count > 0){
            return arr![0]
        }
        return nil
        
    }
//    func getWorkResultUpload() -> [WorkResultModel]? {
//        
//        let sql = "select ShopCode,WorkTime,WorkDate,Locked,Uploaded,_id from WorkResults"// where Uploaded = 0"
//        var arr: [WorkResultModel]?
//        arr = getWorkResults(sql);
//        if(arr != nil && arr!.count > 0){
//            return arr
//        }
//        return nil
//        
//    }
    func getWorkResultUpload() -> [WorkResultModel]? {
        
        let sql = "select ShopCode,WorkTime,WorkDate,Locked,Uploaded,_id from WorkResults where Uploaded = 1"
        var arr: [WorkResultModel]?
        arr = getWorkResults(sql);
        if(arr != nil && arr!.count > 0){
            return arr
        }
        return nil
        
    }
    func setUpload(_ AUDITID: Int,upLoaded: Int){
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="update WorkResults set Uploaded = \(upLoaded) where _id = \(AUDITID)"
        // print(sql)
        connect.Query(sql, database: database)
        
    }

   
    func getWorkResults(_ sql: String) -> [WorkResultModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstWorkResults:[WorkResultModel]=[]
        
        lstWorkResults=getList(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstWorkResults
    }

    func getList(_ statement:OpaquePointer)->[WorkResultModel]{
      
        var lstWorkResults:[WorkResultModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:WorkResultModel = WorkResultModel()
            
            let ShopCode=Function.sqliteGetString(statement, column: 0)
            model.ShopCode = ShopCode
            
            let WorkTime=Function.sqliteGetString(statement, column: 1)
            model.WorkTime = WorkTime
            
            let WorkDate=Function.sqliteGetString(statement, column: 2)
            model.WorkDate = WorkDate == "" ? 0 : Int(WorkDate)!

            
            let Locked=Function.sqliteGetString(statement, column: 3)
            model.Locked = Locked == "" ? 0 : Int(Locked)!
            
            let Uploaded=Function.sqliteGetString(statement, column: 4)
            model.Uploaded = Uploaded == "" ? 0 : Int(Uploaded)!
            
            let Id=Function.sqliteGetString(statement, column: 5)
            model._id = Id == "" ? 0 : Int(Id)!
            
            lstWorkResults.append(model)
        }
        
        return lstWorkResults
        
    }

}
