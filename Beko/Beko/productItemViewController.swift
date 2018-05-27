//
//  productItemViewController.swift
//  Panasonic
//
//  Created by PHUCLONG on 9/21/16.
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


class productItemViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate ,UITextFieldDelegate,PickerSelectProtocol{
    
    
    @IBOutlet weak var txtNumber: UITextField?
    @IBOutlet weak var lbCategory: UILabel!
    @IBOutlet weak var myTable: UITableView!
    var arrProduct : [AuditSKUModel]? = []
    var pageIndex: Int! = 0
    var AUDITID: Int?
    var PARAMATER: UserDefaults = UserDefaults()
    var current_input_tag: Int = 0
    var prev_keyboard_button: UIBarButtonItem = UIBarButtonItem()
    var next_keyboard_button: UIBarButtonItem = UIBarButtonItem()
    
    var lbTitle: String = ""
    var productProvider: ProductProvider = ProductProvider()
    override func viewDidLoad() {
        AUDITID = PARAMATER.object(forKey: "AUDITID") as? Int
        lbCategory.text = lbTitle
        myTable.delegate = self
        myTable.dataSource	 = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(arrProduct == nil){
            return 0
        }
        return arrProduct!.count
        
    }
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTable.dequeueReusableCell(withIdentifier: "cellProductItem", for: indexPath) as! cellItemProduct
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(productItemViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        cell.delegate = self
        cell.txtOOS.delegate = self
         cell.txtOOS.inputAccessoryView = toolbar
        cell.txtPrice.delegate = self
         cell.txtPrice.inputAccessoryView = toolbar
        cell.txtDisplay.delegate = self
         cell.txtDisplay.inputAccessoryView = toolbar
        cell.lbModel.text = arrProduct![indexPath.row].ProductName
        //cell.lbModel.numberOfLines = 0
        //cell.lbModel.lineBreakMode = .ByWordWrapping
        //cell.lbMarket.text = arrProduct![indexPath.row].MarketName
        cell.txtOOS.tag = indexPath.row
        cell.txtPrice.tag = indexPath.row
        cell.txtDisplay.tag = indexPath.row
        if(arrProduct![indexPath.row].Display! != -1){
            cell.txtDisplay.text = String(arrProduct![indexPath.row].Display!)
        }
        else{
            cell.txtDisplay.text = ""
        }

        if(arrProduct![indexPath.row].OOS! != -1){
            cell.txtOOS.text = String(arrProduct![indexPath.row].OOS!)
        }
        else{
            cell.txtOOS.text = ""
        }
        if(arrProduct![indexPath.row].Price != -1){
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
           // cell.txtPrice.text = numberFormatter.String(from: NSNumber(arrProduct![indexPath.row].Price!))
            cell.txtPrice.text = numberFormatter.string(from: NSNumber(value: arrProduct![indexPath.row].Price!))
        }
        else{
            cell.txtPrice.text = ""
        }
        cell.txtPrice.addTarget(self, action: #selector(productItemViewController.textPriceChange(_:)), for: .editingDidEnd)
        cell.txtOOS.addTarget(self, action: #selector(productItemViewController.textChangeOOS(_:)), for: UIControlEvents.editingDidEnd)
     //   cell.txtDisplay.addTarget(self, action: #selector(productItemViewController.textChange(_:)), for: UIControlEvents.editingDidEnd)
        cell.txtPrice.delegate = self
       // cell.txtOOS.delegate = self
       // cell.txtDisplay.delegate = self
        
        
        return cell
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    func checkboxNo(_ sender: UIButton){
        let index = sender.tag
       
        if(arrProduct![index].OOS == 0){
            arrProduct![index].Display = 0
            productProvider.checkInsertSKU(arrProduct![index])
            //myTable.reloadData()
        }
       
    }
    func checkboxYes(_ sender: UIButton){
        let index = sender.tag
        if(arrProduct![index].OOS == 0){
            arrProduct![index].Display = 1
            productProvider.checkInsertSKU(arrProduct![index])
           // myTable.reloadData()
        }

    }
    func textChangeOOS(_ textField: UITextField){
        
        let row = textField.tag
        if(textField.text != ""){
            
            self.arrProduct![row].OOS =  Int(textField.text!)!
            productProvider.checkInsertSKU(arrProduct![row])
           // myTable.reloadData()
        }
    }
//
//    func textChange(_ textField: UITextField){
//        
//        let row = textField.tag
//        if(textField.text != ""){
//            
//            self.arrProduct![row].Display =  Int(textField.text!)!
//            productProvider.checkInsertSKU(arrProduct![row])
//            //myTable.reloadData()
//        }
//    }
    func textPriceChange(_ textField: UITextField){
        
        let row = textField.tag
        if(textField.text != ""){
            
            self.arrProduct![row].Price =  Double(textField.text!.replace(target: ",", withString: "").replace(target: ".", withString: ""))!
            productProvider.checkInsertSKU(arrProduct![row])
            //myTable.reloadData()
        }
    }
    func select(value: String, tag: Int,type: String) {
        if type == "OOS"{
            self.arrProduct![tag].OOS =  Int(value)
        }
        else{
            self.arrProduct![tag].Display =  Int(value)
        }
        
        productProvider.checkInsertSKU(arrProduct![tag])
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
    }
    @IBAction func btTakePhoto(_ sender: AnyObject) {
        
    }
    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        revealViewController().pushFrontViewController(frm, animated: true)
    }
  }
