    //
//  RequestWorkingViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 1/22/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import UIKit

class RequestWorkingViewController: UIViewController,didLoadDelegate {

    @IBOutlet weak var myTable: UITableView!
    var lstRequest = [WorkingModel]()
    var workingProvider = WorkingProvider()
    var SHOPCODE = Preferences.get(key: "SHOPCODE")
    var ACCESS_TOKEN = Preferences.get(key: "ACCESS_TOKEN")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myTable.delegate = self
        myTable.dataSource = self
        loadDataRequest()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btBack(_ sender: Any) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        
        revealViewController().pushFrontViewController(frm, animated: true)

    }
    @IBAction func requestWorking(_ sender: Any) {
        showPopup()
    }
    func showPopup(){
        Preferences.put(key: "WORKINGDATE", value: Date().toShortTimeString())
        let popupWorking = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupWorking") as! PopupWorkingViewController
        popupWorking.delegate = self
        // let popupWorking = self.storyboard?.instantiateViewController(withIdentifier: "popupWorking") as! PopupWorkingViewController
        self.addChildViewController(popupWorking)
        popupWorking.view.frame = self.view.frame
        self.view.addSubview(popupWorking.view)
       
        //self.present(popupWorking, animated: true, completion: nil)
        popupWorking.didMove(toParentViewController: self)

    }
    @IBAction func test(_ sender: Any) {
       
    }
    func loadDataRequest() {
        var model = WorkingModel()
        model.confirm = 0
        model.shopcode = SHOPCODE
        SVProgressHUD.show()

        DispatchQueue.global(qos: .background).async {
            self.workingProvider.getList(self.ACCESS_TOKEN, function: "GETLIST", model: model, completionHandler: { (data, error) in
                DispatchQueue.main.async {
                    if let lst = data {
                        self.lstRequest = lst
                        self.updateUI()
                        
                    }else{
                        return
                    }
                    SVProgressHUD.dismiss()
                }
                
                
            })
        }

    }
}
    extension RequestWorkingViewController: UITableViewDelegate,UITableViewDataSource{
        func updateUI(){
            myTable.reloadData()
        }
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return lstRequest.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellRequest", for: indexPath) as! cellRequest
            cell.lbDate.text       = "Ngày :" + lstRequest[indexPath.row].workingDate
            cell.lbWorking.text    = "Ca mới :" + lstRequest[indexPath.row].working
//            cell.lbWorkingOld.text = "Ca đã chuyển :" + lstRequest[indexPath.row].workingOld
//            if lstRequest[indexPath.row].confirm == 1 {
//                cell.lbStatus.text = "Đã xác nhận"
//                cell.lbStatus.textColor = UIColor.blue
//                cell.lbDate.textColor = UIColor.blue
//            }else{
//                cell.lbStatus.text = "Chưa xác nhận"
//                cell.lbStatus.textColor = UIColor.red
//                cell.lbDate.textColor = UIColor.red
//            }

            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //Preferences.put(key: "WORKINGDATE", value: lstRequest[indexPath.row].workingDate)
            //showPopup()
        }
    }
