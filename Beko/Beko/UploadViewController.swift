//
//  UploadViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 12/18/16.
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


class UploadViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tblDownload: UITableView!
    var lstWorkResult: [WorkResultModel]? = []
    var workResult: WorkResultController = WorkResultController()
    var promotionProvider:PromotionProvider = PromotionProvider()
    var productProvider:ProductProvider = ProductProvider()
    var attendantProvider: AttendantProvider = AttendantProvider()
    var sosProvider:SOSProvider = SOSProvider()
    var http = Http()
    var PARAMATER:UserDefaults = UserDefaults()
    var SHOPCODE:String=""
    var EMPLOYEECODE:String=""
    var ACCESS_TOKEN=""
    var Today:Date = Date()
    var URL_UPLOAD_DATA="http://beko.spiral.com.vn:1000/UploadIos.ashx"
    override func viewDidLoad() {
        super.viewDidLoad()
        lstWorkResult = workResult.getWorkResultUpload()
        tblDownload.delegate = self
        tblDownload.dataSource = self
        EMPLOYEECODE = PARAMATER.object(forKey: "EMPLOYEECODE") as! String
        ACCESS_TOKEN = PARAMATER.object(forKey: "ACCESS_TOKEN") as! String
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
                self.Today = date
        }, errorHandle:{})
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(lstWorkResult != nil){
            return (lstWorkResult?.count)!
        }
        return 0
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblDownload.dequeueReusableCell(withIdentifier: "cellUpload", for: indexPath) as! cellUpload
        cell.lblDate.text = String(lstWorkResult![indexPath.row].WorkDate)
        cell.lblShopName.text = lstWorkResult![indexPath.row].ShopCode
        return cell
    }
    func checkDataUpload(){
        for item in lstWorkResult! {
            if item.Uploaded == 0 {
                return
            }
        }
        Function.Message("Thông báo", message: "Upload dữ liệu thành công")
        tblDownload.reloadData()
        SVProgressHUD.dismiss()
    }
    func checkData(auditId: Int) -> String{
        var lstChecks: [AuditSKUModel]? = []
        lstChecks = productProvider.getDataCheck(auditId)
        if lstChecks != nil && (lstChecks?.count)! > 0{
            for item in lstChecks! {
                if item.Price! < Double(100000) {
                    return  "Bạn phải nhập giá của model \(item.ProductName) - \(item.MarketName) lớn hơn 1 triệu. Kiểm tra và nhập lại"
                }
            }
        }
        return ""
    }

    @IBAction func btUpload(_ sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if lstWorkResult == nil || lstWorkResult?.count == 0{
            Function.Message("Thông báo", message: "Không có dữ liệu để Upload.")
        }
        else{
            let str = ""//checkData(auditId: (lstWorkResult?[0]._id)!)
            if str == "" {
                let serialQueue = DispatchQueue(label: "serialQueue", attributes: [])
                serialQueue.async(execute: {
                    // print("1")
                    self.uploaddata()
                    
                })
            }
            else{
                Function.Message("Thông báo", message: str)
                SVProgressHUD.dismiss()
            }

        }
        
        
    }
    func uploaddata(){
        var attandantDate: Int = self.Today.toIntShortDate()
        if(lstWorkResult != nil && lstWorkResult?.count > 0){
            for result in lstWorkResult! {
                let date = result.WorkTime[result.WorkTime.characters.index(result.WorkTime.startIndex, offsetBy: 0)...result.WorkTime.characters.index(result.WorkTime.startIndex, offsetBy: 10)]
                let jsonWl = getJson(result.ShopCode, WorkDate: date, Type: "WEEKLY", AUDITID: result._id)
                let jsonMl = getJson(result.ShopCode, WorkDate: date, Type: "MONTHLY", AUDITID: result._id)
                let jsonPromotion = getJson(result.ShopCode, WorkDate: date, Type: "PROMOTION", AUDITID: result._id)
                var jsonString = NSString(data: jsonWl, encoding: String.Encoding.utf8.rawValue) as! String
                print(jsonString)
                
                jsonString = NSString(data: jsonWl, encoding: String.Encoding.utf8.rawValue) as! String
                print(jsonString)
                
                jsonString = NSString(data: jsonWl, encoding: String.Encoding.utf8.rawValue) as! String
                print(jsonString)
                
                // print(jsonWl)
                // print(jsonMl)
                // print(jsonPromotion)
                let lstAttendant = attendantProvider.getAttendant(result.WorkDate,shopCode: result.ShopCode, uploaded: 0)
                var arrData = [ImageModel]()
                
                var imgModel = ImageModel()
                imgModel.MimeType = "json"
                imgModel.ImageType = "WEEKLY"
                imgModel.ImageData = jsonWl
                arrData.append(imgModel)
                
                imgModel = ImageModel()
                imgModel.MimeType = "json"
                imgModel.ImageType = "MONTHLY"
                imgModel.ImageData = jsonMl
                arrData.append(imgModel)
                
                imgModel = ImageModel()
                imgModel.MimeType = "json"
                imgModel.ImageType = "PROMOTION"
                imgModel.ImageData = jsonPromotion
                arrData.append(imgModel)
                var jsonAttendance = Data()
                if lstAttendant.count > 0 {
                    jsonAttendance = toJsonAttendance(lstAttendant)
                    jsonString = NSString(data: jsonAttendance, encoding: String.Encoding.utf8.rawValue) as! String
                    print(jsonString)
                    imgModel = ImageModel()
                    imgModel.MimeType = "json"
                    imgModel.ImageType = "ATTENDANCE"
                    imgModel.ImageData = jsonAttendance
                    arrData.append(imgModel)
                    
                    for item in lstAttendant {
                        let imgModel = ImageModel()
                        imgModel.MimeType = "image/jpg"
                        imgModel.ImageType = String(item.attendantphoto.substring(from: 21))
                        let imagePath = Function.getDirectoryPath() + "/\(item.attendantphoto)"
                        let img = UIImage(contentsOfFile: imagePath)
                        imgModel.ImageData = UIImagePNGRepresentation(img!)
                        arrData.append(imgModel)
                    }
                }
                SVProgressHUD.show()
                let queue = DispatchQueue(label: "com.queue.uploaddata")
                queue.async {
                    self.upload(self.ACCESS_TOKEN, function: "UPLOADDATA", urlImage: self.URL_UPLOAD_DATA, attandantDate: result.WorkDate, arr: arrData, completionHandler: { (data, error) in
                        
                        guard data != nil else {
                            SVProgressHUD.dismiss()
                            DispatchQueue.main.async {
                                 Function.Message("Thông báo", message: "Upload lỗi.")
                            }
                           
                            return
                        }
                        // print("sellout")
                        DispatchQueue.main.async {
                            self.workResult.setUpload(result._id,upLoaded: 2)
                            self.lstWorkResult = self.workResult.getWorkResultUpload()
                            self.tblDownload.reloadData()
                            SVProgressHUD.dismiss()

                            Function.Message("Thông báo", message: "Upload thành công.")
                        }
                        
                        
                    })
                    
                }
                
            }
            
        }
        
    }
    func upload(_ access_token: String,function: String,urlImage: String,attandantDate: Int,arr: [ImageModel],completionHandler: @escaping(String?,String?) -> ()){
        let paramaters: [String: String] = ["access_token": access_token,
                                            "AttendantDate": String(attandantDate),
                                            "FUNCTION": function]
        http.uploadFilesWithType(paramaters, URL_UploadImage: urlImage, arrData: arr,completionHandler: completionHandler)
    }
    
    
    func uploadMonthly(){
        
    }
    func uploadPromotion(){
        
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    func toJsonWeekly(_ lst: [AuditSKUModel],ShopCode: String,WorkDate: String) -> [Dictionary<String, AnyObject>] {
        var dictSellOuts: [Dictionary<String, AnyObject>] = []
        for sku in lst{
            let dictS  : [String : AnyObject] = [
                "ShopCode": ShopCode as AnyObject,
                "ShortageDate": WorkDate as AnyObject,
                "ProductCode":  sku.ProductCode as AnyObject,
                "Display": sku.Display! as AnyObject,
                "Stock" : sku.OOS! as AnyObject,
                "Price" : sku.Price! as AnyObject
            ]
            
            
            dictSellOuts.append(dictS)
        }
        return dictSellOuts
    }
    func toJsonMonthly(_ lst: [SOSResultModel],ShopCode: String,WorkDate: String) -> [Dictionary<String, AnyObject>] {
        var dictSellOuts: [Dictionary<String, AnyObject>] = []
        for sku in lst{
            let dictS  : [String : AnyObject] = [
                "ShelfCompetiterID": sku.ShelfCompetiterID! as AnyObject,
                "ShelfShareDate": WorkDate as AnyObject,
                "ShopCode":  ShopCode as AnyObject,
                "Amount": sku.Quantity! as AnyObject
            ]
            
            
            dictSellOuts.append(dictS)
        }
        return dictSellOuts
    }
    func toJsonPromotion(_ lst: [PromotionModel],ShopCode: String,WorkDate: String) -> [Dictionary<String, AnyObject>] {
        var dictSellOuts: [Dictionary<String, AnyObject>] = []
        for sku in lst{
            let dictS  : [String : AnyObject] = [
                "CompetitorID": sku.Competitor! as AnyObject,
                "SaleDate": WorkDate as AnyObject,
                "ShopCode":  ShopCode as AnyObject,
                "Content": sku.Program! as AnyObject,
                "Model": sku.Model! as AnyObject,
                "PromotionEfficiency": sku.Result! as AnyObject,
                "StartDate": sku.FromDate! as AnyObject,
                "EndDate": sku.ToDate! as AnyObject
                
            ]
            
            
            dictSellOuts.append(dictS)
        }
        return dictSellOuts
    }
    func toJsonAttendance(_ lst: [AttendantModel]) -> Data{
        var dictAttendances: [Dictionary<String, AnyObject>] = []
        var jsonString:String = ""
        var data = Data()
        for sku in lst{
            let attTime=Date(timeIntervalSince1970:Double(sku.attendanttime))
            let dictS  : [String : AnyObject] = [
                "Time"  : attTime.toLongTimeStringUpload() as AnyObject,
                "ImageName" : "http://beko.spiral.com.vn:1000/Upload/Images/\(sku.attendantdate)/"+sku.attendantphoto.substring(from: 21) as AnyObject,
                "ImageType" : String(sku.attendanttype) as AnyObject,
                "ShopCode" : sku.shopcode as AnyObject,
                "AttendantDate" : sku.attendantdate as AnyObject,
                "Latitude" : sku.latitude as AnyObject,
                "Longitude" : sku.longitude as AnyObject,
                "Accuracy" : sku.accuracy as AnyObject
            ]
            
            
            dictAttendances.append(dictS)
        }
        do{
            data = try JSONSerialization.data(withJSONObject: dictAttendances, options:.prettyPrinted)
            
        }
        catch let error as NSError{
            print(error.description)
        }
        return data
    }
    
    func getJson(_ ShopCode: String,WorkDate: String,Type: String,AUDITID: Int)->Data{
        
        var jsonString:String=""
        
        var json: [Dictionary<String, AnyObject>] = []
        if Type == "WEEKLY" {
            let lstProduct = productProvider.getUpload(AUDITID)
            if(lstProduct != nil && lstProduct?.count > 0){
                json = toJsonWeekly(lstProduct!,ShopCode: ShopCode,WorkDate: WorkDate)
            }
            
        }
        else if Type == "MONTHLY"{
            let lstSOS = sosProvider.getUpload(AUDITID)
            if(lstSOS != nil && lstSOS?.count > 0){
                json = toJsonMonthly(lstSOS!,ShopCode: ShopCode,WorkDate: WorkDate)
            }
            
        }
        else{
            let lstPromotion = promotionProvider.getListPromotionById(AUDITID)
            if(lstPromotion != nil && lstPromotion?.count > 0){
                json = toJsonPromotion(lstPromotion!,ShopCode: ShopCode,WorkDate: WorkDate)
            }
        }
        do{
            let data = try JSONSerialization.data(withJSONObject: json, options:.prettyPrinted)
            jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            
        }
        catch let error as NSError{
            print(error.description)
        }
        //print(jsonString)
        return jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        
    }
    
}
