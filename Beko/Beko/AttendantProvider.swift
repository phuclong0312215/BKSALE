//
//  AttendantProvider.swift
//  Aqua
//
//  Created by PHUCLONG on 12/18/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import Foundation
class AttendantProvider {
    var connect:CConnect=CConnect(db: "aqua",type: "sqlite")
    
    init(){
        
    }
    func delete(){
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        
        connect.Query("delete from Attendants", database: database)
    }
    
    func insert(_ model:AttendantModel){
        
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="INSERT INTO Attendants(shopcode,attendanttype,uploaded,attendanttime,accuracy,latitude,longitude,attendantdate,attendantphoto) VALUES ('"+model.shopcode+"',"+String(model.attendanttype)+","+String(model.uploaded)+","+String(model.attendanttime)+","+String(model.accuracy)+","+String(model.latitude)+","+String(model.longitude)+","+String(model.attendantdate)+",'"+model.attendantphoto+"')"
        // print(sql)
        connect.Query(sql, database: database)
        
        
    }
    func setUpload(_ id:Int,uploaded:Int){
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="update Attendants set uploaded=\(uploaded) where _id="+String(id)
        // print(sql)
        connect.Query(sql, database: database)
        
    }
    func getListInfo(_ statement:OpaquePointer)->[AttendantModel]{
        
        var lstAttendant:[AttendantModel]=[]
        
        while sqlite3_step(statement)==SQLITE_ROW{
            
            let model:AttendantModel=AttendantModel()
            let uploader=Function.sqliteGetString(statement, column: 0)
            model.uploaded = uploader == "" ? 0 : Int(uploader)!
            
            let attendanttype=Function.sqliteGetString(statement, column: 1)
            model.attendanttype = attendanttype == "" ? 0 : Int(attendanttype)!
            
            let attendanttime=Function.sqliteGetString(statement, column: 2)
            model.attendanttime = attendanttime == "" ? 0 : Int(attendanttime)!
            
            let latitude=Function.sqliteGetString(statement, column: 3)
            model.latitude = latitude == "" ? 0 : Double(latitude)!
            
            let shopcode=Function.sqliteGetString(statement, column: 4)
            model.shopcode = shopcode
            
            let longitude=Function.sqliteGetString(statement, column: 5)
            model.longitude = longitude == "" ? 0 : Double(longitude)!
            
            let attendantdate=Function.sqliteGetString(statement, column: 6)
            model.attendantdate = attendantdate == "" ? 0 : Int(attendantdate)!
            
            let attendantphoto=Function.sqliteGetString(statement, column: 7)
            model.attendantphoto = attendantphoto
            
            let id=Function.sqliteGetString(statement, column: 8)
            model.id = id == "" ? 0 : Int(id)!
            
            lstAttendant.append(model)
        }
        
        return lstAttendant
    }
    func getAttendant(_ attendantDate:Int,shopCode:String,uploaded:Int) -> [AttendantModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="select uploaded,attendanttype,attendanttime,latitude,shopcode,longitude,attendantdate,attendantphoto,_id from Attendants where ShopCode='\(shopCode)' and AttendantDate=\(attendantDate)"
        //print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstAttendant:[AttendantModel]=[]
        
        lstAttendant=getListInfo(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstAttendant
    }
    func getAttendantUpload(_ uploaded:Int) -> [AttendantModel]{
        
        let database:OpaquePointer = connect.Connect_DB_Sqlite()
        let sql="select  uploaded,attendanttype,attendanttime,latitude,shopcode,longitude,attendantdate,attendantphoto,_id from Attendants where uploaded=\(uploaded)"
        // print(sql)
        let statement:OpaquePointer = connect.Select(sql, database: database)
        
        var lstAttendant:[AttendantModel]=[]
        
        lstAttendant=getListInfo(statement)
        
        sqlite3_finalize(statement)
        sqlite3_close(statement)
        
        return lstAttendant
    }
    
    
}
