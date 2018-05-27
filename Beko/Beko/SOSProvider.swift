//
//  SOSProvider.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class SOSProvider{
    
    var connect:CConnect=CConnect(db: "aqua",type: "sqlite")
    
    init(){
        
    }
    func getCategory() -> [SOSModel]?{
        
        var arr: [SOSModel]? = []
        let sql = "SELECT CatName FROM SOS  Group by  CatName ORDER BY CatName"
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
               
        arr=getListCategory(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
    }
    func getByCategory(_ CatName: String,AuditId: Int) -> [SOSResultModel]? {
     
        var arr: [SOSResultModel]? = []
        let sql = "Select s.ShelfCompetiterID,s.CompetitorName,a.Quantity,\(String(AuditId))  as 'AuditId'  from SOS s left join SOSResult a  on  a.ShelfCompetiterID = s.ShelfCompetiterID and a.WorkId = \(AuditId) where s.CatName = '\(CatName)'";// ORDER BY p.Competitor DESC";
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListByCategory(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil

    }
    func getUpload(_ AuditId: Int) -> [SOSResultModel]?{
        
        var arr: [SOSResultModel]? = []
        let sql = "Select ShelfCompetiterID,CompetitorName,Quantity,\(String(AuditId))  as 'AuditId'  from SOSResult where WorkId = \(AuditId)";
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListByCategory(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
    }

    func getListCategory(_ statement:OpaquePointer) -> [SOSModel] {
        
        var lstProduct:[SOSModel]=[]
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:SOSModel=SOSModel()
            
           // let CatCode=Function.sqliteGetString(statement, column: 0)
          //  model.CatCode = CatCode
            
            let CatName=Function.sqliteGetString(statement, column: 0)
            model.CatName = CatName
          
            lstProduct.append(model)
        }
        
        return lstProduct

    }
    func getListByCategory(_ statement:OpaquePointer) -> [SOSResultModel] {
        
        var lstProduct:[SOSResultModel]=[]
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:SOSResultModel=SOSResultModel()
            
         
            let ShelfCompetiterID=Function.sqliteGetString(statement, column: 0)
            model.ShelfCompetiterID = ShelfCompetiterID == "" ? 0 : Int(ShelfCompetiterID)!

            let CompetitorName=Function.sqliteGetString(statement, column: 1)
            model.CompetitorName = CompetitorName
            
            let Quantity=Function.sqliteGetString(statement, column: 2)
            model.Quantity = Quantity == "" ? -1 : Int(Quantity)!

            let AuditId=Function.sqliteGetString(statement, column: 3)
            model.AuditId = AuditId == "" ? 0 : Int(AuditId)!
            lstProduct.append(model)
        }
        
        return lstProduct
        
    }

    func delete(){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from SOS", database: database)
    }

    func insert(_ model: SOSModel) {
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        var sql = "INSERT INTO SOS(CompetitorOrder,CompetitorName,CatName,ShelfCompetiterID,CompetitorID,CatCode) VALUES ('" + String(model.CompetitorOrder!) + "','"
        sql += model.CompetitorName! + "','" + model.CatName! + "'," + String(model.ShelfCompetiterID!) + ","
        sql += String(model.CompetitorID!) + ",'" + model.CatCode! + "')"
        print(sql)
        connect.Query(sql,database: database)
    }
    func updateSOSResult(_ model: SOSResultModel){
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        let sql = "update SOSResult set Quantity = \(model.Quantity!) where ShelfCompetiterID = '\(model.ShelfCompetiterID)' and WorkId = \(model.AuditId)"
        connect.Query(sql, database: database)
        
    }

    func insertSOSResult(_ model:SOSResultModel){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "insert into SOSResult(Quantity,CompetitorName,WorkId,ShelfCompetiterID) values ('\(model.Quantity!)','\(model.CompetitorName!)',\(model.AuditId),\(model.ShelfCompetiterID!))"
        // print(sql)
        connect.Query(sql, database: database)
        // print("OK")
        
    }
    func checkInsertSOSResult(_ model: SOSResultModel){
        if(getByCompetitor(model) == false){
            insertSOSResult(model)
        }
        else{
            updateSOSResult(model)
        }
        
    }
    func getByCompetitor(_ model: SOSResultModel) -> Bool {
        var arr: [SOSResultModel]? = []
        
        let sql = "select CompetitorName from SOSResult where ShelfCompetiterID = \(model.ShelfCompetiterID!) and WorkId = \(model.AuditId)"
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListByCompetitor(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        if(arr != nil && arr!.count > 0){
            return true
        }
        return false
        
    }
    func getListByCompetitor(_ statement:OpaquePointer)->[SOSResultModel]{
        var lstSOS:[SOSResultModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:SOSResultModel=SOSResultModel()
            
            let CompetitorName = Function.sqliteGetString(statement, column: 0)
            model.CompetitorName = CompetitorName
            lstSOS.append(model)
        }
        
        return lstSOS
        
    }

}
