//
//  EmployeeProvider.swift
//  Beko
//
//  Created by PHUCLONG on 10/24/17.
//  Copyright © 2017 PHUCLONG. All rights reserved.
//

import Foundation
class EmployeeProvider {
    var connect:CConnect=CConnect(db: "beko",type: "sqlite")
    
    init(){
        
    }
    func delete(){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from Employees", database: database)
    }
    
    func insert(_ model: EmployeeModel){
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "insert into Employees(EmployeeCode,IsLogin,LoginDate,LogoutDate,Access_token,Level) values ('\(model.EmployeeCode)','\(model.IsLogin)','\(model.LoginDate.toLongTimeString())','\(model.LogoutDate.toLongTimeString())','\(model.Accesstoken)',\(model.Level))"
        // print(sql)
        connect.Query(sql, database: database)
    }
    func logout(){
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "update Employees set IsLogin = 'false'"
        // print(sql)
        connect.Query(sql, database: database)
    }
    func updateLogin(employeeCode: String){
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql = "update Employees set IsLogin = 'true' where EmployeeCode = '\(employeeCode)'"
        // print(sql)
        connect.Query(sql, database: database)
    }
    
    func getUserLogin() -> [EmployeeModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="select EmployeeCode,IsLogin,LoginDate,LogoutDate,Access_token,Level from Employees where IsLogin = 'true'"
        //print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstUser:[EmployeeModel]=[]
        
        lstUser=getListInfo(statement: statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstUser
    }
    func checkEmployeeLogin(employeeCode: String) -> [EmployeeModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="select EmployeeCode,IsLogin,LoginDate,LogoutDate,Access_token,Level from Employees where employeeCode = '\(employeeCode)'"
        //print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstUser:[EmployeeModel]=[]
        
        lstUser=getListInfo(statement: statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstUser
    }
    
    func getListInfo(statement:OpaquePointer)->[EmployeeModel]{
        
        var lstUser:[EmployeeModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:EmployeeModel = EmployeeModel()
            let EmployeeCode = Function.sqliteGetString(statement, column: 0)
            model.EmployeeCode = EmployeeCode
            
            let IsLogin = Function.sqliteGetString(statement, column: 1)
            model.IsLogin = (IsLogin == "" ? nil : Bool(IsLogin)!)!
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //Your date format
            //let date =  //
            let LoginDate = Function.sqliteGetString(statement, column: 2)
            model.LoginDate = (LoginDate == "" ? nil : dateFormatter.date(from: LoginDate))!
            
            let LogoutDate=Function.sqliteGetString(statement, column: 3)
            model.LogoutDate = (LogoutDate == "" ? nil : dateFormatter.date(from: LogoutDate))!
            
            let Accesstoken = Function.sqliteGetString(statement, column: 4)
            model.Accesstoken = Accesstoken
            
            let Level = Function.sqliteGetString(statement, column: 5)
            model.Level = (Level == "" ? nil : Int(Level)!)!
            
            
            lstUser.append(model)
        }
        
        return lstUser
    }
    
}

