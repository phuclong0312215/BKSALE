//
//  MenuViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/1/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tbMenu: UITableView!
    
    var arrMenu:[String] = ["Trang chủ","Tải dữ liệu","Gửi báo cáo","Công cụ","Thoát"]
    var arrImg:[String] = ["ic_action_home.png","ic_action_download.png","ic_action_upload.png","ic_setting.png","ic_action_logout.png"]
    var empProvider = EmployeeProvider()
    override func viewDidLoad() {
        super.viewDidLoad()

        tbMenu.delegate = self
        tbMenu.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let frm = (self.storyboard?.instantiateViewController(withIdentifier: "frmMain"))! as UIViewController
            self.revealViewController().pushFrontViewController(frm, animated: true)
            break
        case 1:
            let frm = (self.storyboard?.instantiateViewController(withIdentifier: "frmDownload"))! as UIViewController
            self.revealViewController().pushFrontViewController(frm, animated: true)
            break
        case 2:
            let frm = (self.storyboard?.instantiateViewController(withIdentifier: "frmUpload"))! as UIViewController
            self.revealViewController().pushFrontViewController(frm, animated: true)
            break
        default:
            empProvider.logout()
            performSegue(withIdentifier: "sw_login",
                         sender: self)

        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbMenu.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath) as! cellMenuTableViewCell
        cell.lbMenu.text = arrMenu[indexPath.row]
        
        cell.imgMenu.image = UIImage(named: arrImg[indexPath.row])
        
        return cell
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
