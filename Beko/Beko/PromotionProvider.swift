//
//  PromotionProvider.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class PromotionProvider{
    
    var connect:CConnect=CConnect(db: "panasonic",type: "sqlite")
    
    init(){
        
    }
    func delete(_ id: Int){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from Promotion where _id = \(id)", database: database)
    }
    
    func insert(_ model:PromotionModel){
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "INSERT INTO Promotion(Program,FromDate,ToDate,Model,Result,WorkId,Competitor) VALUES ('\(model.Program!)','\(model.FromDate!)','\(model.ToDate!)','\(model.Model!)','\(model.Result!)',\(model.WorkId!),\(model.Competitor!))"
        connect.Query(sql,database: database)
        
        
    }
    func getListPromotionById(_ AuditId: Int) -> [PromotionModel]? {
        let sql = "select Program,FromDate,ToDate,Model,Result,WorkId,Competitor,_id from Promotion where WorkId = \(AuditId)";
        var arr: [PromotionModel]? = []
       
        arr = getListPromotionData(sql);
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
    }
    func getListPromotionData(_ sql: String) -> [PromotionModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        // let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstPromotion:[PromotionModel]=[]
        
        lstPromotion=getList(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstPromotion
    }
    func getList(_ statement:OpaquePointer)->[PromotionModel]{
        var lstPromotion:[PromotionModel]=[]
        
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:PromotionModel=PromotionModel()
            
            let Program = Function.sqliteGetString(statement, column: 0)
            model.Program = Program
            
            let FromDate = Function.sqliteGetString(statement, column: 1)
            model.FromDate = FromDate
            
            let ToDate = Function.sqliteGetString(statement, column: 2)
            model.ToDate = ToDate
            
            let Model = Function.sqliteGetString(statement, column: 3)
            model.Model = Model
            
            let Result = Function.sqliteGetString(statement, column: 4)
            model.Result = Result
            
            let WorkId = Function.sqliteGetString(statement, column: 5)
            model.WorkId = WorkId == "" ? 0 : Int(WorkId)!
            
            let Competitor = Function.sqliteGetString(statement, column: 6)
            model.Competitor = Competitor == "" ? 0 : Int(Competitor)!
          
            let Id = Function.sqliteGetString(statement, column: 7)
            model.Id = Id == "" ? 0 : Int(Id)!
            
            lstPromotion.append(model)
        }
        
        return lstPromotion
        
    }

}
