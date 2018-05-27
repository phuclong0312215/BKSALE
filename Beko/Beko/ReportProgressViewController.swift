//
//  ReportProgressViewController.swift
//  Beko
//
//  Created by PHUCLONG on 12/12/17.
//  Copyright © 2017 PHUCLONG. All rights reserved.
//

import UIKit
import AssetsLibrary
class ReportProgressViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var PARAMATER: UserDefaults = UserDefaults()
    var EMPLOYEECODE: String = ""
    var ACCESS_TOKEN: String = ""
    var EMPLOYEENAME: String = ""
    var SHOPCODE: String = ""
    var Today:Date = Date()
    var lstReport: [ReportModel] = []
    var reportProvider = ReportProvider()
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var txtEmployee: UILabel!
    @IBOutlet weak var txtToday: UILabel!
    var URL_UPLOAD_DATA="http://beko.spiral.com.vn:1000/GetData.ashx"
    var FUNCTION: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        SHOPCODE = (PARAMATER.object(forKey: "SHOPCODE") as? String)!
        EMPLOYEENAME = (PARAMATER.object(forKey: "EMPLOYEENAME") as? String)!
         EMPLOYEECODE = (PARAMATER.object(forKey: "EMPLOYEECODE") as? String)!
        ACCESS_TOKEN = (PARAMATER.object(forKey: "ACCESS_TOKEN") as? String)!
        Today = (PARAMATER.object(forKey: "TODAY") as? Date)!
        txtEmployee.text = "\(EMPLOYEENAME)(\(EMPLOYEECODE))"
        txtToday.text = Today.toLongTimeString()
        loadData()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lstReport.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReport", for: indexPath) as! cellReport
        cell.lbPivot.text = String(lstReport[indexPath.row].pivot)
        cell.lbValue.text = String(lstReport[indexPath.row].value)
        return cell
    }
    func loadData(){
        SVProgressHUD.show()
        let queue = DispatchQueue.global()
        queue.async { 
            self.reportProvider.getList(self.ACCESS_TOKEN,shopCode: self.SHOPCODE, completionHandler: { (lst, error) in
                DispatchQueue.main.async(execute: { 
                    if lst != nil{	
                        self.lstReport = lst!
                        self.myTable.reloadData()
                    }
                     SVProgressHUD.dismiss()
                })
            })
        }
    }
    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        
        revealViewController().pushFrontViewController(frm, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
