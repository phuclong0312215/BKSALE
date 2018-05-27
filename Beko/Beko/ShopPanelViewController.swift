//
//  ShopPanelViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/11/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation
class ShopPanelViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate {
    var locations:CLLocation? = nil
   
    @IBOutlet weak var nav: UINavigationItem!
    @IBOutlet weak var imgCheckOut: UIImageView!
    @IBOutlet weak var imgCheckIn: UIImageView!
    @IBOutlet weak var btCheckOut: UIButton!
    @IBOutlet weak var btCheckIn: UIButton!
    @IBOutlet weak var mytable: UITableView!
    @IBOutlet weak var heightConstraintCheckOut: NSLayoutConstraint!
    @IBOutlet weak var heighConstraintCheckIn: NSLayoutConstraint!
    var workResult: WorkResultController = WorkResultController()
    var attendantProvider:AttendantProvider = AttendantProvider()
     var locationManager:CLLocationManager=CLLocationManager()
    var arrTitle:[String] = ["1.Stock out & Display","2.Shelf of share","3.Báo cáo doanh số","4.Chương trình khuyến mãi","5.Báo cáo tiến độ","Chuyển ca làm việc"]
    var arrImg:[String] = ["ic_report_monthly_144.png","ic_report_weekly_144.png","ic_report_sales_144.png","ic_promotion_144.png","ic_progress_144.png","ic_changeworking.png"]
    var SHOPCODE: String = ""
    var EMPLOYEECODE : String = ""
    var ACCESS_TOKEN : String = ""
    var PARAMATER : UserDefaults = UserDefaults()
    var picker=UIImagePickerController()
    var checkAttendant: String = ""
    var Today : Date = Date()
    var AUDITID: Int?
    var URL_UPLOAD_DATA="http://beko.spiral.com.vn:1000/UploadData.ashx"
    let productProvider = ProductProvider()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mytable.delegate = self
        mytable.dataSource = self
        SHOPCODE = PARAMATER.object(forKey: "SHOPCODE") as! String
        AUDITID = PARAMATER.object(forKey: "AUDITID") as? Int
        EMPLOYEECODE = (PARAMATER.object(forKey: "EMPLOYEECODE") as? String)!
        ACCESS_TOKEN = PARAMATER.object(forKey: "ACCESS_TOKEN") as! String
        nav.title = SHOPCODE
       // heighConstraintCheckIn.constant = UIScreen.mainScreen().bounds.width/2
       // heightConstraintCheckOut.constant = UIScreen.mainScreen().bounds.width/2
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        btCheckIn.isEnabled = false
        checkForLocationServices()
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
            self.getImageAttendant()
        }, errorHandle:{
            SVProgressHUD.dismiss()
        })
        
    }
    func checkForLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            if #available(iOS 8.0, *) {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            Function.Message(self,title:"Thông báo", message: "Vui lòng mở và cho phép ứng dụng sử dụng đinh vị GPS"){
                action in
                self.checkForLocationServices()
            }
        }
    }
    
    
    func getImageAttendant(){
        print("getImageAttendant()")
        let fileManager = FileManager.default
        let imagePAth = Function.getDirectoryPath()
        let lstAttendant=attendantProvider.getAttendant(Today.toIntShortDate(),shopCode: SHOPCODE, uploaded: 0)
        btCheckIn.isEnabled = true
        btCheckOut.isEnabled = true
        for  info in lstAttendant {
            info.attendantphoto = "\(imagePAth)/\(info.attendantphoto)"
            if info.attendanttype == 0 {
                
                // print(imagePAth)
                
                //  print(info.attendantphoto)
                if fileManager.fileExists(atPath: info.attendantphoto){
                    imgCheckIn.image = UIImage(contentsOfFile: info.attendantphoto)
                    
                }
                btCheckIn.isEnabled = false
            } else if (info.attendanttype == 1) {
                imgCheckOut.image = UIImage(contentsOfFile: info.attendantphoto)
                btCheckOut.isEnabled = false
            }
        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellShopPanel", for: indexPath) as! cellShopPanel
        cell.img.image = UIImage(named: arrImg[indexPath.row])
        cell.lbl.text = arrTitle[indexPath.row]
        
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Date();
        
        if(Today.toIntShortDate() != date.toIntShortDate()){
            Function.Message("Thông báo", message: "Đồng hồ hệ thống không đúng.")
            return
        }
        
        PARAMATER.setValue(EMPLOYEECODE, forKeyPath: "EMPLOYEECODE")
       // PARAMATER.setValue(ACCESS_TOKEN, forKeyPath: "ACCESS_TOKEN")
        PARAMATER.setValue(Today, forKeyPath: "TODAY")
        PARAMATER.setValue(AUDITID, forKeyPath: "AUDITID")
        if btCheckIn.isEnabled == true {
            Function.Message("Thông báo", message: "Bạn chưa Check in.")
            return
        }

        
        
        switch indexPath.row {
        case 0:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmProduct"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
            break;
        case 1:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmSOS"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
             break;
        case 2:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmSellOut"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
             break;
        case 3:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmPromotion"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
             break;
        case 4:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmReport"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
             break;
        case 5:
            
            let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmWorking"))! as UIViewController
            revealViewController().pushFrontViewController(frm, animated: true)
            break;
        default:
             Function.Message("Thông báo", message: "Chức năng đang cập nhât.")
             break;

        
        }
       

        
    }
    @IBAction func btCheckOut(_ sender: AnyObject) {
        if btCheckIn.isEnabled == false{
            // startCamera("1")
            let str = ""
           // str = checkData()
            if str != ""{
                Function.Message("Thông báo", message: str)
            }
            else{
                Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
                    (date) in
                    self.Today = date
                    self.startCamera("1")
                }, errorHandle:{
                    SVProgressHUD.dismiss()
                })
            }

        }
        else{
            Function.Message("Thông báo", message: "Bạn chưa chụp check in.")
        }
       
    }
    func checkData() -> String{
        var lstChecks: [AuditSKUModel]? = []
        lstChecks = productProvider.getDataCheck(AUDITID!)
        if lstChecks != nil && (lstChecks?.count)! > 0{
            for item in lstChecks! {
//                if item.OOS == -1 {
//                    return  " Bạn chưa nhập Stock cho \(item.ProductName) của \(item.MarketName)"
//                }
//                else if item.Display == -1 {
//                    return " Bạn chưa nhập Display cho \(item.ProductName) của \(item.MarketName)"
//                }
//                else{
                    if item.Price! < Double(100000) {
                        return  "Bạn phải nhập giá của model \(item.ProductName) - \(item.MarketName) lớn hơn 1 triệu. Kiểm tra và nhập lại"
                    }
               // }
            }
            
        }
        return ""
    }

    @IBAction func btCheckIn(_ sender: AnyObject) {
        
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
            self.startCamera("0")
        }, errorHandle:{
            SVProgressHUD.dismiss()
        })
    }
    
    
    func startCamera(_ type: String) {
        if(locations == nil || locations?.coordinate == nil)
        {
            Function.Message(self,title:"Thông báo", message: "Vui lòng mở và cho phép ứng dụng sử dụng đinh vị GPS"){
                action in
                self.checkForLocationServices()
            }
            return
        }
        print("startCamera\(type)")
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            let img=UIImagePickerController()
            img.sourceType = .camera
            
            img.delegate=self
            
            self.picker = img
            checkAttendant = type
            present(self.picker, animated: true,completion:nil)
            
            
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print(".NotDetermined")
            self.locationManager.requestWhenInUseAuthorization()
            
            break
            
        case .authorizedAlways:
            print(".Authorized")
            self.locationManager.startUpdatingLocation()
            break
            
        case .denied:
            print(".Denied")
            Function.Message("Thông báo", message: "Vui lòng mở định vị GPS/Location và cho phép Beko app sử dụng.")
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            print(".WhenInUse")
            self.locationManager.startUpdatingLocation()
            break
        default:
            print("Unhandled authorization status")
            break
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations = locations.last! as CLLocation
        print("\(self.locations)")
    }

    func insertAttendant(_ urlImage:String) -> AttendantModel{
        let model:AttendantModel=AttendantModel()
        model.shopcode = SHOPCODE
        model.attendantphoto=urlImage
        model.uploaded=0
        model.attendantdate=Today.toIntShortDate()
        model.attendanttime=Int(Today.timeIntervalSince1970)
        model.latitude = Double((locations?.coordinate.latitude)!)
        model.longitude = Double((locations?.coordinate.longitude)!)
        model.attendanttype = Int(checkAttendant)!
        attendantProvider.insert(model)
        if model.attendanttype == 1 {
            workResult.setUpload(AUDITID!,upLoaded: 1)
            Function.Message("Thông báo", message: "Vui lòng vào gửi báo cáo để tải dữ liệu hệ thống.")
        }
        return model
    }

    func checkCheckIn()->Bool{
        
        return true
        
    }
    func saveImageDocumentDirectory(_ imageName: String,imgData: Data) -> String{
        let fileManager = FileManager.default
        
        let directory = createDirectory()
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directory + "/" + imageName)
        //print(paths)
        fileManager.createFile(atPath: paths as String, contents: imgData, attributes: nil)
        return "ImageUpload/"+String(Date().toIntShortDate())+"/"+imageName
    }
    func createDirectory() -> String{
        let fileManager = FileManager.default
        let directory = "ImageUpload/"+String(Date().toIntShortDate())
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(directory)
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }else{
            print("Already dictionary created.")
        }
        return directory
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let imageData = UIImageJPEGRepresentation(Function().fixOrientation(image), 0.2)
        //let compressedJPGImage = UIImage(data: imageData!)
        let imageUrl =  saveImageDocumentDirectory(checkAttendant + "_" + Date().toImageName(EMPLOYEECODE)+".jpg", imgData: imageData!)
        
        let model = insertAttendant(imageUrl)
        
        setEnableImageButton(checkAttendant,imageData: imageData)
        dismiss(animated: true, completion: nil)
       // uploadAttendant(model)
    }
    func setEnableImageButton(_ type: String,imageData: Data!) {
        
        switch type {
        case "0":
            imgCheckIn.image = UIImage(data: imageData)
            btCheckIn.isEnabled = false
            break;
        default:
            imgCheckOut.image = UIImage(data: imageData)
            btCheckOut.isEnabled = false
            break;
        }
    }

    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmMain"))! as UIViewController
      //  navigationController?.pushViewController(frm, animated: true)
        
        revealViewController().pushFrontViewController(frm, animated: true)

    }
    func uploadAttendant(_ info: AttendantModel){
        var imageData :Data=Data()
        info.attendantphoto = "\(Function.getDirectoryPath())/\(info.attendantphoto)"
        let image = UIImage(contentsOfFile: info.attendantphoto)
        
        if( image != nil){
            imageData=UIImageJPEGRepresentation(image!, 0.5)!
            DispatchQueue.main.async(execute: { () -> Void in
                // print("gg")
                // print(imageData)
                SVProgressHUD.show()
                self.postAttendant(self.URL_UPLOAD_DATA,model: info,access_token: self.ACCESS_TOKEN, imgData: imageData) { data, error in
                    guard data != nil else {
                        print(error)
                        return
                    }
                     SVProgressHUD.dismiss()
                }
                
                
            })

        }
    }
    func postAttendant(_ url: String,model:AttendantModel,access_token:String,imgData:Data?,completionHandler: @escaping (Data?, NSError?) -> ()) -> URLSessionTask {
        
        
        let request = createRequest(url,model: model, accen_token: access_token, imgData: imgData)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 180.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard data != nil else {
                    completionHandler(nil, error as! NSError)
                    return
                }
                
                completionHandler(data, nil)
            }
        }) 
        task.resume()
        
        return task
    }
    func createRequest (_ url:String,model:AttendantModel,accen_token:String,imgData:Data?) -> URLRequest {
        let attTime=Date(timeIntervalSince1970:Double(model.attendanttime))
        let param = [
            "FUNCTION" : "ATTENDANCE",
            "Time"  : attTime.toLongTimeStringUpload(),
            "ImageName"    : attTime.toImageName(EMPLOYEECODE)+String(model.id)+"iOS.jpg",
            "ImageType" : String(model.attendanttype),
            "ShopCode" : model.shopcode,
            "AttendantDate" : String(model.attendantdate),
            "Latitude" : String(model.latitude),
            "Longitude" : String(model.longitude),
            "Accuracy" : String(model.accuracy),
            "access_token" : accen_token]  // build your dictionary however appropriate
        // print(attTime.toLongTimeStringUpload())
        // print(NSDate().toImageName(EMPLOYEECODE))
        //print(String(model.accuracy))
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        // var imageData = UIImageJPEGRepresentation(imgView.image!, 0.9)
        // var base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)) // encode the image
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //  let path1 = NSBundle.mainBundle().pathForResource("image1", ofType: "png") as String!
        request.httpBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imgData, boundary: boundary)
        
        return request as URLRequest
    }
    func createBodyWithParameters(_ parameters: [String: String], filePathKey: String?, imageDataKey: Data?, boundary: String) -> Data {
        let body = NSMutableData()
        
        // if parameters != nil {
        
        for (key, value) in parameters {
            
            // if value != nil {
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
            //}
        }
        // }
        
        if imageDataKey != nil
        {
            let filename = "user-profile.jpg"
            let mimetype = "image/jpg"
            
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageDataKey!)
            body.appendString("\r\n")
            
            body.appendString("--\(boundary)--\r\n")
        }
        //print(body)
        return body as Data
    }
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

}
