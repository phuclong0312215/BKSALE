//
//  UpdatInfoSellOutViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 12/17/16.
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


class UpdatInfoSellOutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    
    @IBOutlet weak var lbAmount: UILabel!
    @IBOutlet weak var lbId: UILabel!
    @IBOutlet weak var tblSellOut: UITableView!
    @IBOutlet weak var txtProvince: UITextField!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtWard: UITextField!
    @IBOutlet weak var txtVillage: UITextField!
    @IBOutlet weak var txtDistrict: UITextField!
    @IBOutlet weak var txtStreet: UITextField!
    @IBOutlet weak var txtNumberOfHouse: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtCustomer: UITextField!
    @IBOutlet weak var txtModel: UITextField!
    let autocompleteTableView = UITableView(frame: CGRect(x: 112,y: 214,width: 200,height: 120), style: UITableViewStyle.plain)
    var autocompleteUrls = [String]()
    var lstProduct: [ProductModel]? = []
    var lstSellOut: [SellOutModel]? = []
    var productProvider: ProductProvider = ProductProvider()
    var type = "PG"
    var PARAMATER: UserDefaults = UserDefaults()
    var EMPLOYEECODE: String = ""
    var ACCESS_TOKEN: String = ""
    var Today:Date = Date()
    var SHOPCODE: String = ""
    var AUDITID: Int = 0
    var URL_UPLOAD_DATA="http://aqua.spiral.com.vn:1000/GetData.ashx"
    var FUNCTION: String = ""
    var NOSELL: Bool = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        AUDITID = (PARAMATER.object(forKey: "AUDITID") as? Int)!
        SHOPCODE = (PARAMATER.object(forKey: "SHOPCODE") as? String)!
        ACCESS_TOKEN = (PARAMATER.object(forKey: "ACCESS_TOKEN") as? String)!
        Function.checkTime(self, acess_token: ACCESS_TOKEN, handle: {
            (date) in
            self.Today = date
        }, errorHandle:{})
        lstProduct = productProvider.getListProducts()
        txtModel.delegate = self
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.borderColor=UIColor(netHex: 0x46b2e4).cgColor
        autocompleteTableView.layer.borderWidth=1
        // txtSaleDate.enabled = false
        txtSaleDate.text = Today.toShortTimeString()
              self.view.addSubview(autocompleteTableView)
        tblSellOut.delegate = self
        tblSellOut.dataSource = self
        // loadData()
        
    }
    @IBOutlet weak var txtSaleDate: UITextField!
    
    @IBAction func datebegin(_ sender: UITextField!) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(UpdatInfoSellOutViewController.datePickerValueChanged), for: 	UIControlEvents.valueChanged)
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtSaleDate.text = dateFormatter.string(from: sender.date)
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        autocompleteTableView.isHidden = false
        let substring = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if substring == "" {
            autocompleteTableView.isHidden=true
            return true
        }
        searchAutocompleteEntriesWithSubstring(substring)
        return true     // not sure about this - could be false
    }
    
    func searchAutocompleteEntriesWithSubstring(_ substring: String)
    {
        autocompleteUrls.removeAll(keepingCapacity: false)
        
        for info in lstProduct!
        {
            // print(info.model.lowercaseString)
            if info.ProductCode.lowercased().contains(substring.lowercased()) {
                
                // print(info.ProductCode)
                autocompleteUrls.append(info.ProductCode)
            }
        }
        if(autocompleteUrls.count>0){
            autocompleteTableView.reloadData()
        }
        else{
            autocompleteTableView.isHidden=true
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblSellOut {
            return (lstSellOut?.count)!
        }
        return autocompleteUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //  let autoCompleteRowIdentifier = "AutoCompleteRowIdentifier"
        // let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier(autoCompleteRowIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        //cell.layer.borderColor=UIColor.grayColor().CGColor
        // cell.layer.borderWidth=1
        
        //        let border = CALayer()
        //        let width = CGFloat(2.0)
        //        border.borderColor = UIColor.darkGrayColor().CGColor
        //        border.frame = CGRect(x: 0, y: cell.frame.size.height - width, width:  cell.frame.size.width, height: cell.frame.size.height)
        //
        //        border.borderWidth = width
        //        cell.layer.addSublayer(border)
        //        cell.layer.masksToBounds = true
        if(tableView == tblSellOut){
            let cell = tblSellOut.dequeueReusableCell(withIdentifier: "cellItemSellOut", for: indexPath) as! cellSellOut
            cell.lbProductCode.text = String(indexPath.row + 1) + "." + lstSellOut![indexPath.row].ProductCode
            cell.lbQuantity.text = String(lstSellOut![indexPath.row].Quantity)
            cell.lbSaleDate.text = lstSellOut![indexPath.row].SaleDate
            return cell
        }
        else {
            let cell = UITableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "AutoCompleteRowIdentifier")
            let index = indexPath.row as Int
            
            cell.textLabel!.text = autocompleteUrls[index]
            cell.textLabel?.textColor=UIColor.blue
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        if tableView == tblSellOut {
            setFormSellOut(lstSellOut![indexPath.row])
        }
        else {
            txtModel.text = selectedCell.textLabel!.text
            autocompleteTableView.isHidden=true
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 30 // other cell height
        
    }
    
    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        
        revealViewController().pushFrontViewController(frm, animated: true)
    }
    func check()->Bool{
        
        
        if  (txtCustomer.text == "") {
            Function.Message("Thông báo", message: "Bạn chưa nhập tên khách hàng")
            return false
        }
        if (txtMobile.text == ""){
            Function.Message("Thông báo", message: "Bạn chưa nhập SĐT")
            return false
        }
        //        if((txtAddress.text?.isEmpty) != nil){
        //            Alert("Thông báo", message: "Bạn chưa nhập  khách hàng")
        //            return false
        //        }
        if(txtModel.text == ""){
            Function.Message("Thông báo", message: "Bạn chưa nhập tên sản phẩm")
            return false
        }
        
        return true
    }
    
    @IBAction func btUpdate(_ sender: AnyObject) {
        if check() {
            if(lbId.text == ""){
                Function.Message("Thông báo", message: "Bạn chưa chọn dữ liệu cập nhật")
                return
            }
            SVProgressHUD.show()
            let model:SellOutModel=SellOutModel()
            model.Comment = txtComment.text!
            model.WorkId = AUDITID
            model.Customer = txtCustomer.text!
            model.Mobile = txtMobile.text!
            model.ProductCode = txtModel.text!
            model.Village = txtVillage.text!
            model.Ward = txtWard.text!
            model.NumberHouse = txtNumberOfHouse.text!
            model.Province = txtProvince.text!
            model.Street = txtStreet.text!
            model.District = txtDistrict.text!
            model.Type = self.type
            model.Address = (model.NumberHouse == "" ? "" : (model.NumberHouse + ",")) + (model.Street == "" ? "" : (model.Street + ",")) + (model.Village == "" ? "" : (model.Village + ",")) + (model.Ward == "" ? "" : (model.Ward + ",")) + (model.District == "" ? "" : (model.District + ",")) + (model.Province == "" ? "" : model.Province)
            
            model.SaleDate = self.txtSaleDate.text!
            model.SaleID = Double(lbId.text!)!
            model.Quantity = Int(lbAmount.text!)!
            model.ShopCode = SHOPCODE
            FUNCTION = "SAVE"
            uploadSellOut(model)
        }
        
    }
    @IBAction func tbGetList(_ sender: AnyObject) {
        loadData()
    }
    func uploadSellOut(_ sellOut: SellOutModel){
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.postSellOut(self.URL_UPLOAD_DATA, function: "DATA", access_token: self.ACCESS_TOKEN,sellOut: sellOut) { (data, error) -> () in
                guard data != nil else {
                    print(error)
                    return
                }
                if(self.FUNCTION == "GETLISTUPDATE"){
                    
                    do{
                        
                        let result =  try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
                        self.getSellOutList(result)
                        self.tblSellOut.reloadData()
                        
                    }
                    catch{
                        SVProgressHUD.dismiss()
                    }
                    
                }else if(self.FUNCTION == "SAVE"){
                    Function.Message("Thông báo", message: "Lưu thành công.")
                    //self.lstSellOut?.append(sellOut)
                    //self.tblSellOut.reloadData()
                }
                
                
                
                
                SVProgressHUD.dismiss()
                
                
                
            }
        })
    }
    func getSellOutList(_ result:[String:AnyObject]){
        
        // print(result["Content"])
        if(result["Content"]?.count>0){
            for i in 0...(result["Content"]!.count)!-1{
                
                
                if let infos = result["Content"] as? [AnyObject],let info = infos[i] as? [String: AnyObject] {
                    let obj: SellOutModel = SellOutModel()
                    obj.SaleID = (info["SaleID"] as! Double)
                    obj.SaleDate = (info["SaleDate"] as! String)
                    obj.Customer = (info["Customer"] as! String)
                    obj.Street = (info["Street"] as! String)
                    obj.Ward = (info["Ward"] as! String)
                    obj.District = (info["District"] as! String)
                    obj.Province = (info["Province"] as! String)
                    obj.NumberHouse = (info["NumberHouse"] as! String)
                    obj.Village = (info["Village"] as! String)
                    obj.Comment = (info["Comment"] as! String)
                    obj.Quantity = (info["Quantity"] as! Int)
                    obj.ProductCode = (info["ProductCode"] as! String)
                    obj.Mobile = (info["Mobile"] as! String)
                    lstSellOut?.append(obj)
                }
                
            }
            
        }
        
    }
    func setFormSellOut(_ sellOut: SellOutModel){
        
        txtSaleDate.text = sellOut.SaleDate
        txtCustomer.text = sellOut.Customer
        txtMobile.text = sellOut.Mobile
        txtStreet.text = sellOut.Street
        txtNumberOfHouse.text = sellOut.NumberHouse
        txtWard.text = sellOut.Ward
        txtVillage.text = sellOut.Village
        txtProvince.text = sellOut.Province
        txtDistrict.text = sellOut.District
        txtModel.text = sellOut.ProductCode
        txtComment.text = sellOut.Comment
        lbId.text = String(sellOut.SaleID)
        lbAmount.text = String(sellOut.Quantity)
    }
    func createRequestSellOut(_ url: String,accen_token: String,sellOut: SellOutModel) -> URLRequest {
        let param = [
            "FUNCTION" : FUNCTION,
            "Quantity" : lbAmount.text!,
            "Type" : "1",
            "SaleId" : String(Int(sellOut.SaleID)),
            "ProductCode":sellOut.ProductCode,
            "CreateDate" : sellOut.SaleDate,
            "CustomerName" : sellOut.Customer,
            "Mobile" : sellOut.Mobile,
            "Address" : sellOut.Address,
            "NumberHouse" : sellOut.NumberHouse,
            "Street" : sellOut.Street,
            "Village" : sellOut.Village,
            "Ward" : sellOut.Ward,
            "District" : sellOut.District,
            "Province" : sellOut.Province,
            "ShopCode" : SHOPCODE,
            "Comment" : sellOut.Comment,
            "access_token" : accen_token]
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        request.httpBody = createBodyWithParametersJson(param, boundary: boundary)
        
        
        return request as URLRequest
    }
    func createBodyWithParametersJson(_ parameters: [String: String], boundary: String) -> Data {
        //print(parameters)
        let body = NSMutableData()
        
        // if parameters != nil {
        
        for (key, value) in parameters {
            
            // if value != nil {
            //print(value)
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
            
            //}
        }
        body.appendString("--\(boundary)--\r\n")
        // print(body)
        // }
        
        return body as Data
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    func postSellOut(_ url:String,function: String,access_token: String,sellOut: SellOutModel,completionHandler:@escaping (Data?,NSError?) -> ()) -> URLSessionTask{
        
        let request = createRequestSellOut(url, accen_token: access_token,sellOut: sellOut)
        
        // request.HTTPBody=createBodyWithParametersJson(params, filePathKey: "file", json: jsonData, boundary:boundary)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
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
      
    func loadData(){
        SVProgressHUD.show()
        lstSellOut = []
        let model:SellOutModel=SellOutModel()
        model.SaleDate = txtSaleDate.text!
        model.ProductCode = txtModel.text!
        FUNCTION = "GETLISTUPDATE"
        uploadSellOut(model)
        
    }
    
    
    
}
