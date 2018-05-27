//
//  PromotionViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 12/16/16.
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


class PromotionViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    var datePickerView:UIDatePicker = UIDatePicker()
   let autocompleteTableView = UITableView(frame: CGRect(x: 112,y: 214,width: 200,height: 120), style: UITableViewStyle.plain)
    @IBOutlet weak var txtToDate: UITextField!
    @IBOutlet weak var txtFromDate: UITextField!
    @IBOutlet weak var pvCompetitor: UITextField!
    
    @IBOutlet weak var txtResult: UITextField!
    @IBOutlet weak var txtProgram: UITextField!
    @IBOutlet weak var txtModel: UITextField!
    var autocompleteUrls = [String]()
    var pickView: UIPickerView = UIPickerView()
    @IBOutlet weak var tblPromotion: UITableView!
    var type: String = ""
    var lstPromotion: [PromotionModel]? = []
    var lstProduct: [ProductModel]? = []
    var promotionProvider: PromotionProvider = PromotionProvider()
    var productProvider: ProductProvider = ProductProvider()
    var pickCompetitor: [String] = ["","AQUA","LG","Daikin","Panasonic","Toshiba","Hitachi","Samsung","Electrolux","Sharp","GE","Mitsu","Beko","Gree","Midea","Funiki","Reeteck","Tatung","OTHER"]
    var AUDITID: Int = 0
    var PARAMATER: UserDefaults = UserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        AUDITID = (PARAMATER.object(forKey: "AUDITID") as? Int)!
        datePickerView.datePickerMode = UIDatePickerMode.date
        lstPromotion = promotionProvider.getListPromotionById(AUDITID)
        lstProduct = productProvider.getListProducts()
        tblPromotion.delegate = self
        tblPromotion.dataSource = self
        pickView.dataSource = self
        pickView.delegate = self
        pvCompetitor.inputView = pickView
        autocompleteTableView.delegate = self
        autocompleteTableView.dataSource = self
        autocompleteTableView.isScrollEnabled = true
        autocompleteTableView.isHidden = true
        autocompleteTableView.layer.borderColor=UIColor(netHex: 0x46b2e4).cgColor
        autocompleteTableView.layer.borderWidth=1
        txtModel.delegate = self
        self.view.addSubview(autocompleteTableView)
        addDoneButton()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        if tableView == autocompleteTableView {
            txtModel.text = selectedCell.textLabel!.text
            autocompleteTableView.isHidden=true
        } else {
            setFormPromotion(lstPromotion![indexPath.row])
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == autocompleteTableView){
            return autocompleteUrls.count
        } else{
            if lstPromotion != nil {
                return (lstPromotion?.count)!
            }
        }
       
        return 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == autocompleteTableView){
            let cell = UITableViewCell(style: UITableViewCellStyle.default , reuseIdentifier: "AutoCompleteRowIdentifier")
            let index = indexPath.row as Int
            
            cell.textLabel!.text = autocompleteUrls[index]
            cell.textLabel?.textColor=UIColor.blue
            return cell
        } else{
            let cell = tblPromotion.dequeueReusableCell(withIdentifier: "cellPromotion", for: indexPath) as! cellPromotion
            cell.lbPromotion.text = String(indexPath.row + 1) + "." + lstPromotion![indexPath.row].Program!
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView!, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if(tableView == tblPromotion){
            if(editingStyle == UITableViewCellEditingStyle.delete){
                
                if let tv = tableView {
                    //  selloutProvider.delete(SHOPCODE, model: lstSellout![indexPath.row].model)
                    let id = lstPromotion![indexPath.row].Id
                    lstPromotion?.remove(at: indexPath.row)
                    tv.deleteRows(at: [indexPath], with: .fade)
                    promotionProvider.delete(id!)
                }
                
            }
            
            
        }

    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickCompetitor.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickCompetitor[row]
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pvCompetitor.text = pickCompetitor[row]
    }
    
    
       
    func datePickerValueChanged(_ sender:UIDatePicker) {
        
        if type == "TO" {
              txtToDate.text = getDate(sender)
        } else{
              txtFromDate.text = getDate(sender)
        }
      
        
    }

    func  getDate(_ sender:UIDatePicker) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: sender.date)
    }
    
    @IBAction func dateEditingToDate(_ sender: UITextField) {
        type = "TO"
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.date = Date()
        sender.inputView = datePickerView
        sender.text = getDate(datePickerView)
        
        datePickerView.addTarget(self, action: #selector(PromotionViewController.datePickerValueChanged), for: 	UIControlEvents.valueChanged)
    }
    @IBAction func dateEditingFromDate(_ sender: UITextField) {
        
        type = "FROM"
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        sender.text = getDate(datePickerView)
        datePickerView.addTarget(self, action: #selector(PromotionViewController.datePickerValueChanged), for: 	UIControlEvents.valueChanged)
    }
    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        
        revealViewController().pushFrontViewController(frm, animated: true)
    }
    
    
    @IBAction func btnClear(_ sender: AnyObject) {
        txtModel.text = ""
        txtProgram.text = ""
        pvCompetitor.text = ""
        txtFromDate.text = ""
        txtToDate.text = ""
        txtResult.text = ""
    }
    @IBAction func btnAdd(_ sender: AnyObject) {
        if check() {
            let promotion: PromotionModel = PromotionModel()
            promotion.Model = txtModel.text
            promotion.Competitor = getCompetitorId(pvCompetitor.text!)
            promotion.FromDate = txtFromDate.text
            promotion.ToDate = txtToDate.text
            promotion.Result = txtResult.text
            promotion.Program = txtProgram.text
            promotion.WorkId = AUDITID
            promotionProvider.insert(promotion)
            //lstPromotion?.append(promotion)
            lstPromotion = promotionProvider.getListPromotionById(AUDITID)
            tblPromotion.reloadData()
        }
    }
    func setFormPromotion(_ promotion: PromotionModel){
        txtModel.text = promotion.Model
        txtFromDate.text = promotion.FromDate
        txtToDate.text = promotion.ToDate
        txtProgram.text = promotion.Program
        txtResult.text = promotion.Result
        if(promotion.Competitor < 9){
            pvCompetitor.text = pickCompetitor[promotion.Competitor! - 1]

        }
        else {
            pvCompetitor.text = pickCompetitor[promotion.Competitor! - 9]
        }
    }
    func getCompetitorId(_ Competitor: String) -> Int {
        for i in 0..<18{
            if pickCompetitor[i] == Competitor {
                if(i<8){
                    return i+1
                } else {
                    return i+9
                }
                
            }
        }
        return 0
    }
    
    @IBOutlet weak var btAdd: UIButton!
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
                
                print(info.ProductCode)
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
    func check() -> Bool {
        if  (pvCompetitor.text == "") {
            Function.Message("Thông báo", message: "Bạn chưa chọn tên hãng.")
            return false
        }
        if  (txtProgram.text == "") {
            Function.Message("Thông báo", message: "Bạn chưa nhập tên chương trình.")
            return false
        }
        if (txtModel.text == ""){
            Function.Message("Thông báo", message: "Bạn chưa nhập tên sản phẩm")
            return false
        }
        return true
    }
    func addDoneButtonOnKeyboard(_ textField: UITextField) {
        let keyboardDoneButtonShow = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: self.view.frame.size.height/17))
        //Setting the style for the toolbar
        keyboardDoneButtonShow.barStyle = UIBarStyle.default
        //Making the done button and calling the textFieldShouldReturn native method for hidding the keyboard.
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(PromotionViewController.doneButtonAction(_:)))
        //Calculating the flexible Space.
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        //Setting the color of the button.
        doneButton.tintColor = UIColor.blue
        //Making an object using the button and space for the toolbar
        let toolbarButton = [flexSpace,doneButton]
        //Adding the object for toolbar to the toolbar itself
        keyboardDoneButtonShow.setItems(toolbarButton, animated: false)
        //Now adding the complete thing against the desired textfield
        textField.inputAccessoryView = keyboardDoneButtonShow
        
    }
    func doneButtonAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    func addDoneButton(){
        addDoneButtonOnKeyboard(txtProgram)
        addDoneButtonOnKeyboard(txtResult)
        addDoneButtonOnKeyboard(txtToDate)
        addDoneButtonOnKeyboard(txtFromDate)
        addDoneButtonOnKeyboard(pvCompetitor)
    }
}
