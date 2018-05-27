//
//  SOSItemViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 10/24/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class SOSItemViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    @IBOutlet weak var myTable: UITableView!
    var pageIndex: Int! = 0
    var arrSOS : [SOSResultModel]? = []
    @IBOutlet weak var lbCat: UILabel!
    var sosProvider: SOSProvider =  SOSProvider()
    var lbTitle: String = ""
    override func viewDidLoad() {
        
        lbCat.text = lbTitle;
        myTable.delegate = self
        myTable.dataSource	 = self

    }
    func numberOfSections(in tableView: UITableView) -> Int {
      
        return 1
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(arrSOS == nil){
            return 0
        }
        return arrSOS!.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(arrSOS![indexPath.row].GroupBy == nil || arrSOS![indexPath.row].GroupBy == ""){
            return 53
        }
        
        return 88
        
        
        
    }
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = myTable.dequeueReusableCell(withIdentifier: "cellSOSItem", for: indexPath) as! cellItemSOS
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SOSItemViewController.doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        cell.lbCompetitor.text = arrSOS![indexPath.row].CompetitorName
        cell.lbMarketCompetitor.text = arrSOS![indexPath.row].GroupBy

        //cell.lbMarket.text = arrProduct![indexPath.row].MarketName
        cell.txtValue.tag = indexPath.row
        cell.txtValue.inputAccessoryView = toolbar
        cell.txtValue.delegate = self
      //  addDoneButtonOnKeyboard(cell.txtValue,width: self.view.frame.width,height: self.view.frame.height)
        if(arrSOS![indexPath.row].Quantity == -1){
            cell.txtValue.text = ""
        } else{
             cell.txtValue.text = String(Int(arrSOS![indexPath.row].Quantity!))
        }
         if(arrSOS![indexPath.row].GroupBy == nil || arrSOS![indexPath.row].GroupBy == ""){
            
            cell.heightContrainst.constant = 0
        }
        else{
            // cell.lbMarket.hidden = true
            
            cell.heightContrainst.constant = 35
            
        }

        cell.txtValue.addTarget(self, action: #selector(SOSItemViewController.textChange(_:)), for: UIControlEvents.editingDidEnd)
        
        return cell
    }
   
    @IBAction func btBack(_ sender: AnyObject) {
        let frm=(self.storyboard?.instantiateViewController(withIdentifier: "frmShopPanel"))! as UIViewController
        revealViewController().pushFrontViewController(frm, animated: true)

    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    func textChange(_ textField: UITextField){
        
        let row = textField.tag
        if(textField.text != ""){
            
            self.arrSOS![row].Quantity =  Int(textField.text!)!
            sosProvider.checkInsertSOSResult(arrSOS![row])
            // arrProduct![row].Display = 2
            
           // myTable.reloadData()
            
            // productProvider.update(self.arrProduct![row])
            
        }
        
        // model.MarketName = textField.text!
        
        
    }

}
