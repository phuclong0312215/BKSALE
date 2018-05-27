//
//  ConnectSQLite.swift
//  demosqLite
//
//  Created by m on 12/30/15.
//  Copyright © 2015 demo. All rights reserved.
//

import Foundation

class CConnect{
    
    var databaseName:String
    var typeName:String
    init(db:String,type:String){
        
        self.databaseName=db
        self.typeName=type
    }
    
    func Select(_ query:String,database:OpaquePointer)->OpaquePointer{
        var statement:OpaquePointer? = nil
        
        
        sqlite3_prepare_v2(database, query, -1, &statement, nil)
        
        // tra ve 1 danh sach
        return statement!
    }
    
    
    //insert, update, delete
    func Query(_ sql:String,database:OpaquePointer){
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        let result = sqlite3_exec(database, sql, nil, nil, &errMsg);
        print(sql)
        print(result)
        print(SQLITE_OK)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Cau truy van bi loi!")
            return
        }
    }
    
    func GetDocumentDirectory()->NSString{
        
       // let fileManager : NSFileManager = NSFileManager.defaultManager()
        let homeDir = NSHomeDirectory() + "/Documents"
        return homeDir as NSString
    }

    //ket noi database
    func Connect_DB_Sqlite()->OpaquePointer{
        var database:OpaquePointer? = nil
        var dbPath:String = ""
        //        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        //        var defaultStorePath:NSString = ""
        //        let storePath : NSString = documentsPath.stringByAppendingPathComponent(databaseName)
        //        let fileManager : NSFileManager = NSFileManager.defaultManager()
        //print(storePath)
        //        var fileCopyError:NSError? = NSError()
        //  print(databaseName)
        //  print(typeName)
        // dbPath = NSBundle.mainBundle().pathForResource(databaseName , ofType:typeName)!
        dbPath=self.GetDocumentDirectory().appending("/beko.sqlite")
        
        print(dbPath)
        //        do {
        //            try fileManager.copyItemAtPath(dbPath, toPath: storePath as String)
        //        }catch {
        //
        //        }
        //        fileManager.copyItemAtPath(dbPath, toPath: storePath, error: nil)
        let result = sqlite3_open(dbPath, &database)
        // print(result)
        //        var result = sql(dbPath, &database, SQLITE_OPEN_READWRITE,nil)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
        }
        return database!
    }
    

}

