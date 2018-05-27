//
//  ShopProvider.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class ShopProvider{
    
    var connect:CConnect=CConnect(db: "aqua",type: "sqlite")
    
    init(){
        
    }
    func delete(){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from shops", database: database)
    }
    
    func insert(_ model:ShopModel){
        
        alterTable()
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("INSERT INTO shops(shopcode,shopname,address,workDate) VALUES ('"+model.shopCode!+"','"+model.shopName!+"','"+model.shopAddress!+"',\(model.workDate ?? 0))", database: database)
        
        
    }
//    func getListShopUpload()->[ShopModel]{
//        
//        let database:COpaquePointer = connect.Connect_DB_Sqlite()
//        let sql="select a.ShopCode,a.AttendantDate,s.ShopName  from ( select ShopCode,AttendantDate from attendants where uploaded=0 group by ShopCode,AttendantDate union select  ShopCode,Date  from Photos where isuploaded=0 group by ShopCode,Date) a join Shop s on s.ShopCode=a.ShopCode"
//        // print(sql)
//        let statement:COpaquePointer = connect.Select(sql, database: database)
//        
//        var lstShop:[ShopModel] = []
//        
//        while sqlite3_step(statement)==SQLITE_ROW{
//            
//            let model:ShopModel = ShopModel()
//            
//            let workdate=Function.sqliteGetString(statement, column: 1)
//            model.workdate = workdate == "" ? 0 : Int(workdate)!
//            
//            
//            let shopcode=Function.sqliteGetString(statement, column: 0)
//            model.shopcode = shopcode
//            
//            
//            let shopname=Function.sqliteGetString(statement, column: 2)
//            model.shopname = shopname
//            
//            lstShop.append(model)
//            
//        }
//        return lstShop
//    }
    func getAllShop()->[ShopModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        let statement:OpaquePointer = connect.Select("select ShopCode,ShopName,Address from shops", database: database)
        
        var lstShop:[ShopModel] = []
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:ShopModel = ShopModel()
            let shopCode = Function.sqliteGetString(statement, column: 0)
            model.shopCode = shopCode
            
            let shopName = Function.sqliteGetString(statement, column: 1)
            model.shopName = shopName
            
            let address = Function.sqliteGetString(statement, column: 2)
            model.shopAddress = address
            
            lstShop.append(model)
            
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstShop
        
    }
    func alterTable(){
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        do{
            connect.Query("ALTER TABLE shops ADD COLUMN workDate INTEGER;", database: database)
        }catch{
            
        }
        sqlite3_close(database)
    }
    func getShops(_ workDate:Int?)->[ShopModel]{
          alterTable()
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        let sql = "select ShopCode,ShopName,Address from shops WHERE workDate=\(workDate ?? 0)"
      print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstShop:[ShopModel] = []
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:ShopModel = ShopModel()
            let shopCode = Function.sqliteGetString(statement, column: 0)
            model.shopCode = shopCode
            
            let shopName = Function.sqliteGetString(statement, column: 1)
            model.shopName = shopName
            
            let address = Function.sqliteGetString(statement, column: 2)
            model.shopAddress = address
            
            lstShop.append(model)
            
        }
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstShop
        
    }
    
}
