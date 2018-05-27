//
//  AppDelegate.swift
//  Beko
//
//  Created by PHUCLONG on 1/17/17.
//  Copyright © 2017 PHUCLONG. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.CheckAndCreateDatabase()
        IQKeyboardManager.sharedManager().enable = true
        return true
    }
    func GetDocumentDirectory()->NSString{
        
        //let fileManager : NSFileManager = NSFileManager.defaultManager()
        let homeDir = NSHomeDirectory() + "/Documents"
        return homeDir as NSString
    }
    

    func CheckAndCreateDatabase(){
        var success:Bool=true
        
        let fileManager:FileManager = FileManager.default
        
        let databasePath:NSString = self.GetDocumentDirectory().appending("/beko.sqlite") as NSString
        
        // print(databasePath)
        
        success = fileManager.fileExists(atPath: databasePath as String)
        
        //        if (success) {
        //            print("working")
        //        }
        //        else{
        //            print("not working")
        //        }
        
        let databasePathfromApp:NSString = ((Bundle.main.resourcePath)! + "/beko.sqlite" as NSString)
        
        //  print(databasePathfromApp)
        
        do {
            try fileManager.copyItem(atPath: databasePathfromApp as String, toPath: databasePath as String)
            
        }catch {
        }
        
        
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

