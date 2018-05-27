//
//  SellOutViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 10/24/16.
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
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

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
class SellOutViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var tblSellOut: UITableView!
    @IBOutlet weak var ckNoSell: UIButton!
    @IBOutlet weak var txtComment: UITextField!
    @IBOutlet weak var txtMobile: UITextField!
    @IBOutlet weak var txtCustomer: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
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
    var SHOPCODE: String = ""
    var AUDITID: Int = 0
    var Today: Date = Date()
    var URL_UPLOAD_DATA="http://beko.spiral.com.vn:1000/GetData.ashx"
    var FUNCTION: String = ""
    var NOSELL: Bool = false
    var picker: UIPickerView = UIPickerView()
    var data: [String] = ["1","2","3","4","5","6","7"]
    override func viewDidLoad() {
        
        super.viewDidLoad()
        AUDITID = (PARAMATER.object(forKey: "AUDITID") as? Int)!
        SHOPCODE = (PARAMATER.object(forKey: "SHOPCODE") as? String)!
        ACCESS_TOKEN = (PARAMATER.object(forKey: "ACCESS_TOKEN") as? String)!
        Today = (PARAMATER.object(forKey:"TODAY") as? Date)!
        lstProduct = productProvider.getListProducts()
        txtModel.delegate=self
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.borderColor=UIColor(netHex: 0x46b2e4).cgColor
        autocompleteTableView.layer.borderWidth=1
        txtAmount.keyboardType =  UIKeyboardType.numberPad
        txtSaleDate.isEnabled = false
        txtSaleDate.text = Today.toShortTimeString()
        txtAmount.text = "1"
        //addDoneButton()
        self.view.addSubview(autocompleteTableView)
        tblSellOut.delegate = self
        tblSellOut.dataSource = self
        picker.delegate = self
        picker.dataSource = self
        txtAmount.inputView = picker
        loadData()
        
    }
    @IBOutlet weak var txtSaleDate: UITextField!
    
    @IBAction func DateEditing(_ sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(SellOutViewController.datePickerValueChanged), for: 	UIControlEvents.valueChanged)
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
            if info.ProductName.lowercased().contains(substring.lowercased()) {
                
                // print(info.ProductCode)
                autocompleteUrls.append(info.ProductName)
            }
        }
        if(autocompleteUrls.count>0){
            autocompleteTableView.reloadData()
        }
        else{
            autocompleteTableView.isHidden=true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        	self.view.endEditing(true)
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView!, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(tableView == tblSellOut){
            if(editingStyle == UITableViewCellEditingStyle.delete){
                
                if let tv = tableView {
                    //  selloutProvider.delete(SHOPCODE, model: lstSellout![indexPath.row].model)
                    let saleId = lstSellOut![indexPath.row].SaleID
                    lstSellOut?.remove(at: indexPath.row)
                    tv.deleteRows(at: [indexPath], with: .fade)
                    let model:SellOutModel=SellOutModel()
                    model.SaleID = saleId
                    FUNCTION = "DELETE"
                    uploadSellOut(model)
                }
                
            }
            
            
        }
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
        if (lstProduct?.first(where: { (item) -> Bool in
            return item.ProductName == txtModel.text!
        })) == nil{
            Function.Message("Thông báo", message: "Sản phẩm không hơph lệ")
            return false
        }
        if(txtAmount.text == ""){
            Function.Message("Thông báo", message: "Bạn chưa nhập số lượng sản phẩm")
            return false
        }
        let amount = Int(txtAmount.text!)
        if(amount <= 0){
            Function.Message("Thông báo", message: "Số lượng sản phẩm phải lớn hơn 0")
            return false
        }
        
        return true
    }
    
    @IBAction func btAddSellOut(_ sender: AnyObject) {
        if check() {
            
            SVProgressHUD.show()
            let model:SellOutModel=SellOutModel()
            model.Comment = txtComment.text!
            model.Quantity = Int(txtAmount.text!)!
            model.WorkId = AUDITID
            model.Customer = txtCustomer.text!
            model.Mobile = txtMobile.text!
            model.ProductCode = txtModel.text!
            model.Type = self.type
            model.Address = txtAddress.text!
            if(self.type == "PG"){
                model.SaleDate = Today.toShortTimeString()
            }
            else{
                model.SaleDate = self.txtSaleDate.text!
            }
            
            model.ShopCode = SHOPCODE
            FUNCTION = "SAVE"
            uploadSellOut(model)
        }
        
        
    }
    func uploadSellOut(_ sellOut: SellOutModel){
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.postSellOut(self.URL_UPLOAD_DATA, function: "DATA", access_token: self.ACCESS_TOKEN,sellOut: sellOut) { (data, error) -> () in
                guard data != nil else {
                    print(error)
                    return
                }
                if(self.FUNCTION == "GETLIST"){
                    
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
                    self.loadData()
                }
                else if(self.FUNCTION == "NOSELL"){
                    Function.Message("Thông báo", message: "Lưu thành công.")
                    
                }
                else{
                    Function.Message("Thông báo", message: "Xoá thành công.")
                }

                
                
                
                SVProgressHUD.dismiss()
                
                
                
            }
        })
    }
    func getSellOutList(_ result:[String:AnyObject]){
        
        if(result["Content"]?.count>0){
            for i in 0...(result["Content"]!.count)!-1{
                if let infos = result["Content"] as? [AnyObject],let info = infos[i] as? [String: AnyObject] {
                    
                    let obj: SellOutModel = SellOutModel()
                    obj.SaleID = (info["SaleID"] as! Double)
                    obj.SaleDate = (info["SaleDate"] as! String)
                    if  !(info["Customer"] is NSNull){
                        obj.Customer = (info["Customer"] as! String)
                        
                    }
                    if  !(info["Comment"] is NSNull){
                        obj.Comment = (info["Comment"] as! String)
                    }
                    
                    obj.Quantity = (info["Quantity"] as! Int)
                    obj.ProductCode = (info["ProductCode"] as! String)
                    if  !(info["Mobile"] is NSNull){
                        obj.Mobile = (info["Mobile"] as! String)
                    }
                    if  !(info["Address"] is NSNull){
                        obj.Address = (info["Address"] as! String)
                    }
                    lstSellOut?.append(obj)
                }
                
            }
            
        }
        
    }
    func clearFormSellOut(){
        txtCustomer.text = ""
        txtMobile.text = ""
        txtAddress.text = ""
        txtModel.text = ""
        txtAmount.text = ""
        txtComment.text = ""
    }
    func setFormSellOut(_ sellOut: SellOutModel){
        
        txtSaleDate.text = sellOut.SaleDate
        txtCustomer.text = sellOut.Customer
        txtMobile.text = sellOut.Mobile
        txtModel.text = sellOut.ProductCode
        txtAmount.text = String(sellOut.Quantity)
        txtComment.text = sellOut.Comment
        txtAddress.text = sellOut.Address
    }
    func createRequestSellOut(_ url: String,accen_token: String,sellOut: SellOutModel) -> URLRequest {
        let param = [
            "FUNCTION" : FUNCTION,
            "Type" : sellOut.Type == "PG" ? "1" : "2",
            "SaleId" : String(Int(sellOut.SaleID)),
            "ProductCode":sellOut.ProductCode,
            "CreateDate" : sellOut.SaleDate,
            "CustomerName" : sellOut.Customer,
            "Mobile" : sellOut.Mobile,
            "Address" : sellOut.Address,
            "Quantity" : String(sellOut.Quantity),
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
       
    @IBAction func checkNoSell(_ sender: AnyObject) {
        NOSELL = !NOSELL
        if(NOSELL == true){
            FUNCTION = "NOSELL"
            ckNoSell.setBackgroundImage(UIImage(named:"ic_checked.png"), for: UIControlState())
            SVProgressHUD.show()
            let model:SellOutModel=SellOutModel()
            model.SaleDate = Today.toShortTimeString()
            uploadSellOut(model)
        }else{
            ckNoSell.setBackgroundImage(UIImage(named:"ic_check.png"), for: UIControlState())
        }
        
    }
//    @IBAction func checkStoreList(_ sender: AnyObject) {
//        self.type = "STORE"
//        txtSaleDate.isEnabled = true
//        ckStoreList.setBackgroundImage(UIImage(named:"ic_radio_checked.png"), for: UIControlState())
//        ckPG.setBackgroundImage(UIImage(named:"ic_radio.png"), for: UIControlState())
//        lstSellOut = []
//        loadData()
//    }
//    @IBAction func checkPG(_ sender: AnyObject) {
//        self.type = "PG"
//        txtSaleDate.isEnabled = false
//        txtSaleDate.text = Date().toShortTimeString()
//       // ckStoreList.setBackgroundImage(UIImage(named:"ic_radio.png"), for: UIControlState())
//        ckPG.setBackgroundImage(UIImage(named:"ic_radio_checked.png"), for: UIControlState())
//        lstSellOut = []
//        loadData()
//    }
    func loadData(){
        SVProgressHUD.show()
        lstSellOut = []
        let model:SellOutModel=SellOutModel()
        model.SaleDate = Today.toShortTimeString()
        model.Type = self.type
        FUNCTION = "GETLIST"
        uploadSellOut(model)
        
    }
    
    @IBAction func clear(_ sender: AnyObject) {
        clearFormSellOut()
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtAmount.text = data[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return data[row]
    }

}
