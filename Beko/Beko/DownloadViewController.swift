//
//  DownloadViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/2/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var myTable: UITableView!
    var arrTitle:[String] = ["1/4.Danh sách cửa hàng","2/4.Danh sách sản phẩm","3/4.Danh sách Competitor"]
    var arrDes:[String] = ["Danh sách cửa hàng","Danh sách sản phẩm","Danh sách Competitor"]
    var arrStatus : [String] = ["Chưa tải","Chưa tải","Chưa tải"]
    var arrDownload : [String] = ["SHOPS","PRODUCTS","COMPETITOR"]
    var EMPLOYEECODE : String = ""
    var ACCESS_TOKEN : String = ""
    var Today:Date = Date()
    var PARAMATER : UserDefaults = UserDefaults()
    var httpPost : Http = Http()
    var URL_DownloadStore="http://beko.spiral.com.vn:1000/DownloadData.ashx"
    var shopProvider : ShopProvider = ShopProvider()
    var productProvider : ProductProvider = ProductProvider()
    var sosProvider : SOSProvider = SOSProvider()
    var promotionProvider : PromotionProvider = PromotionProvider()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        EMPLOYEECODE = PARAMATER.object(forKey: "EMPLOYEECODE") as! String
        ACCESS_TOKEN = PARAMATER.object(forKey: "ACCESS_TOKEN") as! String
        
        
        myTable.dataSource=self
        myTable.delegate=self
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
        }, errorHandle:{
            SVProgressHUD.dismiss()
        })
        // Do any additional setup after loading the view.
    }
    func checkUpload(){
        
        var flag: Bool?
        for str in arrStatus {
            if str == "Da tai ve" {
                flag = true
            }
            else{
                flag = false
                break
            }
            
        }
        if flag == true{
            print("finish")
            SVProgressHUD.dismiss()
            let alert = UIAlertView(title: "Download successfully.", message: "", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        }
        else{
            print("suspend")
        }
    }
    
    @IBAction func DownloadData(_ sender: AnyObject) {
        SVProgressHUD.show()
        shopProvider.delete()
        productProvider.delete()
        sosProvider.delete()
        
        var i:Int = 0
        
        DispatchQueue.main.async(execute: { () -> Void in
            for str in self.arrDownload {
                
                
                print(str)
                self.httpPost.post(self.URL_DownloadStore, function: str, acess_token: self.ACCESS_TOKEN) { data, error in
                    guard data != nil else {
                        print(error)
                        return
                    }
                    
                    // let str=NSString(data: data!, encoding: NSUTF8StringEncoding)
                    // print(str as! String)
                    
                    do{
                        
                        let result =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        print(result)
                        
                        self.InsertData(str, result: result)
                        self.arrStatus[i]="Da tai ve"
                        self.checkUpload()
                        self.myTable.reloadData()
                        i += 1
                        //self.shopProvider.show()
                        
                        
                    }catch {
                        
                        print("error")
                    }
                    
                }
                
                
            }
            
        })
        
        
        
        
        
        //        SVProgressHUD.dismiss()
        //        let alert = UIAlertView(title: "Download successfully.", message: "", delegate: nil, cancelButtonTitle: "OK")
        //        alert.show()
        
    }
    func InsertData(_ function:String,result:[String:AnyObject]) {
        
        switch function {
        case "SHOPS":
            getShops(result)
            break;
        case "COMPETITOR":
            getSOS(result)
            break;
        case "PRODUCTS":
            getProducts(result)
            break;
        default:
            
            break;
        }
        
    }
    func getSOS(_ result:[String:AnyObject]){
        
        if result["Content"]!.count > 0 {
            
            for i in 0...(result["Content"]!.count)!-1{
                
                
                if let infos = result["Content"] as? [AnyObject],let info = infos[i] as? [String: AnyObject] {
                    let obj: SOSModel = SOSModel()
                    
                    obj.CompetitorName = (info["CompetitorName"] as! String)
                    obj.ShelfCompetiterID = (info["ShelfCompetiterID"] as! Int)
                    obj.CatName = (info["CatName"] as! String)
                    obj.CatCode = (info["CatCode"] as! String)
                    obj.CompetitorOrder = (info["CompetitorOrder"] as! Int)
                    obj.CompetitorID = (info["CompetitorID"] as! Int)
                    
                    sosProvider.insert(obj)
                    //arrShop.append(obj)
                }
                
            }
        }
    }
    
    func getShops(_ result:[String:AnyObject]){
        
        if result["Content"]!.count > 0 {
            
            for i in 0...(result["Content"]!.count)!-1{
                
                
                if let infos = result["Content"] as? [AnyObject],let info = infos[i] as? [String: AnyObject] {
                    let obj:ShopModel = ShopModel()
                    obj.shopCode = (info["ShopCode"] as! String)
                    obj.shopName = (info["ShopName"] as! String)
                    obj.workDate = Today.toIntShortDate()
                    if  !(info["Address"] is NSNull)   {
                        obj.shopAddress = (info["Address"] as! String)
                    }
                    shopProvider.insert(obj)
                }
                //arrShop.append(obj)
            }
        }
        
    }
    
    func getProducts(_ result:[String:AnyObject]){
        
        if result["Content"]!.count > 0 {
            
            for i in 0...(result["Content"]!.count)!-1{
                
                if let infos = result["Content"] as? [AnyObject],let info = infos[i] as? [String: AnyObject] {
                    
                    let obj:ProductModel = ProductModel()
                    obj.ProductCode = info["ProductCode"] as! String
                    
                    if  !(info["CatCode"] is NSNull)   {
                        obj.CatCode=info["CatCode"] as! String
                    }
                    if  !(info["ListOrder"] is NSNull)   {
                        obj.ListOrder=info["ListOrder"] as! Int
                    }
                    if  !(info["OrderMarket"] is NSNull)   {
                        obj.OrderMarket=info["OrderMarket"] as! Int
                    }
                    if  !(info["CatName"] is NSNull)   {
                        obj.CatName=info["CatName"] as! String
                    }
                    if  !(info["MarketCode"] is NSNull)   {
                        obj.MarketCode=info["MarketCode"] as! String
                    }
                    if  !(info["MarketName"] is NSNull)   {
                        obj.MarketName=info["MarketName"] as! String
                    }
                    if  !(info["Division"] is NSNull)   {
                        obj.Division=info["Division"] as! String
                    }
                    if  !(info["ProductName"] is NSNull)   {
                        obj.ProductName=info["ProductName"] as! String
                    }
                    if  !(info["EffectiveDate"] is NSNull)   {
                        obj.EffectiveDate=info["EffectiveDate"] as! String
                    }
                    if  !(info["Active"] is NSNull)   {
                        obj.Status = info["Active"] as! Int
                    }
                    //  obj.imageurl=info["ImageUrl"] as! String
                    //  obj.latitude=info["Latitude"] as! String
                    //  obj.longitude=info["Longitude"] as! String
                    //  obj.workdate=info["WorkDate"] as! Int
                    productProvider.insert(obj)
                    //arrShop.append(obj)
                }
            }
        }
    }
    func isNotNSNull(_ object:AnyObject) -> Bool {
        return object.classForCoder != NSNull.classForCoder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTable.dequeueReusableCell(withIdentifier: "cellDownload", for: indexPath) as! cellDownloadTableViewCell
        cell.lbTitle.text = arrTitle[indexPath.row]
        cell.lbDescription.text = arrDes[indexPath.row]
        cell.lbStatus.text = arrStatus[indexPath.row]
        return cell
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
