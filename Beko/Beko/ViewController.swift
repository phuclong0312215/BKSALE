//
//  ViewController.swift
//  Beko
//
//  Created by PHUCLONG on 1/17/17.
//  Copyright © 2017 PHUCLONG. All rights reserved.
//

import UIKit
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    var EMPLOYEECODE : String = ""
    var EMPLOYEENAME : String = ""
    var ACCESS_TOKEN : String = ""
    var SHOPCODE : String = ""
    var LEVEL : Int = 0

    var URL_LOGIN:String="http://beko.spiral.com.vn:1000/Login.ashx";
    var PARAMATER : UserDefaults = UserDefaults()
    var htppPost : Http = Http()
    var employeeProvider = EmployeeProvider()
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view1: UIView!
    @IBAction func Login(_ sender: AnyObject) {
        if(txtUserName.text==""){
            
            Function.Message("Thông báo", message: "Chưa nhập UserName")
            
        }
        else{
            
            LoginApp(txtUserName.text!, password: txtPassword.text!)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    func checkIsLogin(){
        let lstUser = employeeProvider.getUserLogin()
        if lstUser.count > 0 {
            self.PARAMATER.setValue(lstUser[0].EmployeeCode, forKeyPath: "EMPLOYEECODE")
            self.PARAMATER.setValue(lstUser[0].EmployeeName, forKeyPath: "EMPLOYEENAME")
            self.PARAMATER.setValue(lstUser[0].Accesstoken, forKeyPath: "ACCESS_TOKEN")
            self.PARAMATER.setValue(lstUser[0].Level, forKeyPath: "LEVEL")
           
            Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
                (date) in
                self.PARAMATER.setValue(date, forKeyPath: "TODAY")
                self.performSegue(withIdentifier: "VCShop", sender: self)
            }, errorHandle:{})
        }
    }
    

    func LoginApp(_ username : String,password : String) {
        
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        print("kk")
        //progress.set
        SVProgressHUD.show()
        htppPost.postLogin(URL_LOGIN, username: username, password: password) { data, error in
            guard data != nil else {
                print(error)
                return
            }
            
            //let str=NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            
            do{
                
                let result =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    SVProgressHUD.dismiss()
                    do {
                        
                        if let emp: NSDictionary = try result["Content"] as? NSDictionary {
                            self.EMPLOYEECODE =  (emp.object(forKey:"EmployeeCode") as? String)!
                            self.EMPLOYEENAME =  (emp.object(forKey:"EmployeeName") as? String)!
                            self.ACCESS_TOKEN = (emp.object(forKey:"access_token") as? String)!
                            self.LEVEL = 2
                            let dateFormatter = Function.getDateFormater()
                            // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            // dateFormatter.timeZone = TimeZone.ReferenceType.local
                            let lstUser = self.employeeProvider.checkEmployeeLogin(employeeCode: self.EMPLOYEECODE)
                            if lstUser.count > 0 {
                                self.employeeProvider.updateLogin(employeeCode: self.EMPLOYEECODE)
                            }
                            else{
                                let emp = EmployeeModel()
                                emp.EmployeeCode = self.EMPLOYEECODE
                                emp.IsLogin = true
                                emp.Accesstoken = self.ACCESS_TOKEN
                                emp.Level = self.LEVEL
                                emp.LoginDate = dateFormatter.date(from: Date().toLongTimeString())!
                                emp.LogoutDate = dateFormatter.date(from: Date().toLongTimeString())!
                                self.employeeProvider.insert(emp)
                            }
                            
                            //print(self.EMPLOYEECODE)
                            // print(self.ACCESS_TOKEN)
                            //self.PARAMATER.setValue(self.SHOPCODE, forKeyPath: "SHOPCODE")
                            self.PARAMATER.setValue(self.EMPLOYEECODE, forKeyPath: "EMPLOYEECODE")
                            self.PARAMATER.setValue(self.ACCESS_TOKEN, forKeyPath: "ACCESS_TOKEN")
                            self.PARAMATER.setValue(String(self.LEVEL), forKeyPath: "LEVEL")
                            self.PARAMATER.setValue(self.EMPLOYEENAME, forKeyPath: "EMPLOYEENAME")
                            self.PARAMATER.setValue(Date(), forKeyPath: "TODAY")
                            self.performSegue(withIdentifier: "VCShop", sender: self)
                        }
                        else{
                            SVProgressHUD.dismiss()
                            Function.Message("Thông báo", message: "\(String(describing: result["Content"]))")
                        }
                    }
                    catch{
                         SVProgressHUD.dismiss()
                        Function.Message("Thông báo", message: "Không tìm thấy tài khoản")
                    }
                })
                
                
                
            }catch {
                 SVProgressHUD.dismiss()
                Function.Message("Thông báo", message: "Không đúng password")
               
                
            }
            
        }
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
//        view1.layer.borderColor=UIColor(netHex: 0x46b2e4).CGColor
//        view1.layer.borderWidth=1
//        
//        view2.layer.borderColor=UIColor(netHex: 0x46b2e4).CGColor
//        view2.layer.borderWidth=1
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "back_ground.png")
        backgroundImage.contentMode = UIViewContentMode.scaleToFill
        self.view.insertSubview(backgroundImage, at: 0)
      
        
        checkIsLogin()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

