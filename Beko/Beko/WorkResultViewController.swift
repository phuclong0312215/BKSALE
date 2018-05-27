//
//  WorkResultViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 10/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WorkResultViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var myTable: UITableView!
    var arrWorkResult: [WorkResultModel]?
    var workResultController: WorkResultController = WorkResultController()
    var PARAMATER: UserDefaults = UserDefaults()
    var shopCode: String = ""
    var Today: Date = Date()
    var WORKRESULT: WorkResultModel? = WorkResultModel()
    override func viewDidLoad() {
        
        myTable.dataSource = self
        myTable.delegate = self
        shopCode = PARAMATER.object(forKey: "SHOPCODE") as! String
        let ACCESS_TOKEN = PARAMATER.object(forKey: "ACCESS_TOKEN") as! String
       
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
            self.loadData()
        }, errorHandle:{
            SVProgressHUD.dismiss()
        })
    }
    
    @IBAction func btBack(_ sender: AnyObject) {
        
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmMain"))! as UIViewController
        revealViewController().pushFrontViewController(frm, animated: true)

    }
    @IBAction func btAddWorkResult(_ sender: AnyObject) {
        
        WORKRESULT = workResultController.getWorkResultCurrent(shopCode, workDate: Today.toIntShortDate())
        if(WORKRESULT == nil){
            let model: WorkResultModel = WorkResultModel()
            model.ShopCode = shopCode
            model.WorkDate = Today.toIntShortDate()
            model.WorkTime = Today.toLongTimeString()
            model.Locked = 0
            model.Uploaded = 0
            WORKRESULT = workResultController.insert(model)
        }
        PARAMATER.setValue(WORKRESULT?._id, forKey: "AUDITID")
       
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        revealViewController().pushFrontViewController(frm, animated: true)

        
    }
    func loadData(){
        
        arrWorkResult = workResultController.getByShop(shopCode)
        myTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrWorkResult == nil {
            return 0
        }
        return (arrWorkResult?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTable.dequeueReusableCell(withIdentifier: "cellWorkResult", for: indexPath) as! cellWorkResult
        if(arrWorkResult != nil && arrWorkResult?.count > 0){
            
            cell.lbShopCode.text = arrWorkResult![indexPath.row].ShopCode
            cell.lbDate.text = arrWorkResult![indexPath.row].WorkTime
        }
        
        return cell
        
    }
    
}
