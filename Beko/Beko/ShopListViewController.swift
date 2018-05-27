//
//  ShopListViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/11/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    var lstShop: [ShopModel] = []
    var shopProvider: ShopProvider = ShopProvider()
    var PARAMATER: UserDefaults = UserDefaults()
    var EMPLOYEECODE: String = ""
    var ACCESS_TOKEN: String = ""
    var Today: Date = Date()
    @IBOutlet weak var myTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        EMPLOYEECODE = PARAMATER.object(forKey: "EMPLOYEECODE") as! String
        ACCESS_TOKEN = PARAMATER.object(forKey: "ACCESS_TOKEN") as! String
        
        myTable.delegate = self
         myTable.dataSource = self
        SVProgressHUD.show()
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
            self.loadData()
        }, errorHandle:{
            SVProgressHUD.dismiss()
        })
    }
    
    func loadData() {
        
        lstShop = shopProvider.getShops(Today.toIntShortDate())
       myTable.reloadData()
        SVProgressHUD.dismiss()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return lstShop.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        PARAMATER.setValue(lstShop[indexPath.row].shopCode, forKey: "SHOPCODE")
        PARAMATER.setValue(EMPLOYEECODE, forKeyPath: "EMPLOYEECODE")
        PARAMATER.setValue(ACCESS_TOKEN, forKeyPath: "ACCESS_TOKEN")
        
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmWorkResult"))! as UIViewController
        revealViewController().pushFrontViewController(frm, animated: true)

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellShop", for: indexPath) as! cellShopTableViewCell
        cell.lbShopAddress.text = lstShop[indexPath.row].shopAddress
        cell.lbShopCode.text = lstShop[indexPath.row].shopCode
        cell.lbShopName.text = lstShop[indexPath.row].shopName
        
        return cell
    }
}
