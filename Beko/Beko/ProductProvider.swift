//
//  ProductProvider.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import Foundation

class ProductProvider {
    
    var connect:CConnect=CConnect(db: "aqua",type: "sqlite")
    var count: Int = 0
    init(){
        
    }
    func delete(){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from Products", database: database)
    }
    
    func insert(_ model:ProductModel){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "INSERT INTO Products(ProductCode,ProductName,MarketCode,MarketName,CatCode,CatName,Division,Unit,ListOrder,Status,OrderMarket) VALUES ('"+model.ProductCode+"','"+String(model.ProductName)+"','"+model.MarketCode+"','"+String(model.MarketName)+"','"+String(model.CatCode)+"','"+model.CatName+"','"+model.Division+"','"+String(model.Unit)+"',"+String(model.ListOrder)+","+String(model.Status)+","+String(model.OrderMarket)+")"
        // print(sql)
        connect.Query(sql, database: database)
        // print("OK")
        
    }
    func insertSKU(_ model:AuditSKUModel){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "insert into AuditSKU(ProductCode,WorkId,OOS,Display,Price) values ('\(model.ProductCode)',\(model.AuditId),\(model.OOS!),\(model.Display!),\(model.Price!))"
        // print(sql)
        connect.Query(sql, database: database)
        // print("OK")
        
    }
    func checkInsertSKU(_ model: AuditSKUModel){
        if(getByProductCode(model) == false){
            insertSKU(model)
        }
        else{
            updateSKU(model)
        }
        
    }
    func getCategory() -> [ProductModel]?{
        
        var arr: [ProductModel]? = []
        let sql = "SELECT  ProductCode,ProductName,MarketCode,MarketName,CatCode,CatName,Division,Unit,ListOrder,Status,OrderMarket  FROM Products Group by  CatCode"
        arr = getProducts(sql);
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
        
    }
    func updateSKU(_ modelSKU: AuditSKUModel){
               let database:OpaquePointer = connect.Connect_DB_Sqlite()

        let sql = "update AuditSKU set Price = \(modelSKU.Price!), Display = \(modelSKU.Display!),OOS = \(modelSKU.OOS!) where ProductCode = '\(modelSKU.ProductCode)' and WorkId = \(modelSKU.AuditId)"
        connect.Query(sql, database: database)

    }
    func getByProductCode(_ model: AuditSKUModel) -> Bool {
        var arr: [AuditSKUModel]? = []

        let sql = "select ProductCode from AuditSKU where ProductCode = '\(model.ProductCode)' and WorkId = \(model.AuditId)"
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getByProduct(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        if(arr != nil && arr!.count > 0){
            return true
        }
        return false

    }
    func getDataCheck(_ auditId: Int) -> [AuditSKUModel]?{
        
        var arr: [AuditSKUModel]? = []
        var sql = "SELECT p.ProductCode,p.ProductName,p.MarketCode,p.MarketName,a.Display,a.OOS,a.Price,'" + String(auditId) + "' as 'AuditId',p.CatCode FROM AuditSku a left join Products p on p.ProductCode = a.ProductCode where a.WorkId = \(auditId) and  (Display > -1 or OOS > -1  or a.Price > -1)";
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListByCat(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
        
    }

    func getUpload(_ AUDITID: Int) -> [AuditSKUModel]? {
        var arr: [AuditSKUModel]? = []
        
        let sql = "SELECT ProductCode,Display,OOS,Price from AuditSKU where WorkId = \(AUDITID)"
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListUpload(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil

    }
    func getbyCategory(_ catCode: String,auditId: Int) -> [AuditSKUModel]?{
        
        var arr: [AuditSKUModel]? = []
      
        let sql = "SELECT p.ProductCode,p.ProductName,p.MarketCode,p.MarketName,a.Display,a.OOS,a.Price,'" + String(auditId) + "' as 'AuditId',p.CatCode" + " from Products p left join AuditSKU a on a.ProductCode = p.ProductCode and a.WorkId =" + String(auditId) + " where p.CatCode = '" + catCode + "'"
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        //let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        
        arr=getListByCat(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)

        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil
        
    }
    func getListProducts() -> [ProductModel]? {
        var arr: [ProductModel]? = []
        let sql = "SELECT  ProductCode,ProductName,MarketCode,MarketName,CatCode,CatName,Division,Unit,ListOrder,Status,OrderMarket  FROM Products"
        arr = getProducts(sql);
        if(arr != nil && arr!.count > 0){
            return arr!
        }
        return nil

    }
    func getProducts(_ sql: String) -> [ProductModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
       // let sql="select * from ProductModel"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstProduct:[ProductModel]=[]
        
        lstProduct=getList(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstProduct
    }
    func getListUpload(_ statement:OpaquePointer) -> [AuditSKUModel] {
        var lstProduct:[AuditSKUModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:AuditSKUModel=AuditSKUModel()
            
            let ProductCode=Function.sqliteGetString(statement, column: 0)
            model.ProductCode = ProductCode
            
            let Display=Function.sqliteGetString(statement, column: 1)
            model.Display = Display == "" ? -1 : Int(Display)!
            let OOS=Function.sqliteGetString(statement, column: 2)
            model.OOS = OOS == "" ? -1 : Int(OOS)!
            
            let Price=Function.sqliteGetString(statement, column: 3)
            model.Price = Price == "" ? -1 : Double(Price)!
            
            
            
            lstProduct.append(model)
        }
        
        return lstProduct

    }
    func getList(_ statement:OpaquePointer)->[ProductModel]{
        var lstProduct:[ProductModel]=[]
        
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:ProductModel=ProductModel()
            
            let ProductCode=Function.sqliteGetString(statement, column: 0)
            model.ProductCode = ProductCode
            
            let ProductName=Function.sqliteGetString(statement, column: 1)
            model.ProductName = ProductName
            
            let MarketCode=Function.sqliteGetString(statement, column: 2)
            model.MarketCode = MarketCode
            
            let MarketName=Function.sqliteGetString(statement, column: 3)
            model.MarketName = MarketName
            
            let CatCode=Function.sqliteGetString(statement, column: 4)
            model.CatCode = CatCode
            
            let CatName=Function.sqliteGetString(statement, column: 5)
            model.CatName = CatName
            
            let Division=Function.sqliteGetString(statement, column: 6)
            model.Division = Division
            
            let Unit=Function.sqliteGetString(statement, column: 7)
            model.Unit = Unit
            
            let ListOrder=Function.sqliteGetString(statement, column: 8)
            model.ListOrder = ListOrder == "" ? 0 : Int(ListOrder)!
            
            
            let Status=Function.sqliteGetString(statement, column: 9)
            model.Status = Status == "" ? 0 : Int(Status)!
            
            let OrderMarket=Function.sqliteGetString(statement, column: 10)
            model.OrderMarket = OrderMarket == "" ? 0 : Int(OrderMarket)!
            
            //
            //            let Active=Function.sqliteGetString(statement, column: 11)
            //            model.Active = Active == "" ? 0 : Int(Active)!
            
            
            
            lstProduct.append(model)
        }
        
        return lstProduct
        
    }

    func getListByCat(_ statement:OpaquePointer)->[AuditSKUModel]{
        var lstProduct:[AuditSKUModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:AuditSKUModel=AuditSKUModel()
            
            let ProductCode=Function.sqliteGetString(statement, column: 0)
            model.ProductCode = ProductCode
            
            let ProductName=Function.sqliteGetString(statement, column: 1)
            model.ProductName = ProductName

            let MarketCode=Function.sqliteGetString(statement, column: 2)
            model.MarketCode = MarketCode

            let MarketName=Function.sqliteGetString(statement, column: 3)
            model.MarketName = MarketName

            let Display=Function.sqliteGetString(statement, column: 4)
            model.Display = Display == "" ? -1 : Int(Display)!
            let OOS=Function.sqliteGetString(statement, column: 5)
            model.OOS = OOS == "" ? -1 : Int(OOS)!
            
            let Price=Function.sqliteGetString(statement, column: 6)
            model.Price = Price == "" ? -1 : Double(Price)!

            
            let AuditId=Function.sqliteGetString(statement, column: 7)
            model.AuditId = AuditId == "" ? 0 : Int(AuditId)!
            
            let CatCode=Function.sqliteGetString(statement, column: 8)
            model.CatCode = CatCode
            
            lstProduct.append(model)
        }
        
        return lstProduct
        
    }
    func getByProduct(_ statement:OpaquePointer)->[AuditSKUModel]{
        var lstProduct:[AuditSKUModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:AuditSKUModel=AuditSKUModel()
            
            let ProductCode=Function.sqliteGetString(statement, column: 0)
            model.ProductCode = ProductCode
            lstProduct.append(model)
        }
        
        return lstProduct
        
    }
    

    
}
