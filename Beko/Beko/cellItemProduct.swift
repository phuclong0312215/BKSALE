//
//  cellItemProduct.swift
//  Panasonic
//
//  Created by PHUCLONG on 9/21/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

protocol PickerSelectProtocol {
    func select(value: String,tag: Int,type: String)
}
class cellItemProduct: UITableViewCell ,UIPickerViewDataSource,UIPickerViewDelegate{

    @IBOutlet weak var contrainMarket: NSLayoutConstraint!
    @IBOutlet weak var lbMarket: UILabel!
    @IBOutlet weak var lbModel: UILabel!
    
    @IBOutlet weak var txtDisplay: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtOOS: UITextField!
   // @IBOutlet weak var checkbox: checkboxControl!
    
    @IBOutlet weak var imgTakePhoto: UIButton!
    @IBOutlet weak var lbName: UILabel!
    var data: [String] = ["","1","2","3","4","5"]
    var picker = UIPickerView()
    var pickerDisplay = UIPickerView()
    var delegate: PickerSelectProtocol?
    @IBAction func valueChanged(_ sender: AnyObject) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //picker.delegate = self
        //picker.dataSource = self
       // txtOOS.inputView = picker
        pickerDisplay.delegate = self
        pickerDisplay.dataSource = self
        txtDisplay.inputView = pickerDisplay
    }
    
    @IBAction func btTakePhoto(_ sender: AnyObject) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let r = txtOOS.tag
        if pickerView == picker{
            txtOOS.text = data[row]
            if row > 0 {
                delegate?.select(value: data[row], tag: r,type: "OOS")
            }
            else{
                delegate?.select(value: "-1", tag: r,type: "OOS")
            }

        }
        else{
            txtDisplay.text = data[row]
            if row > 0 {
                delegate?.select(value: data[row], tag: r,type: "DIS")
            }
            else{
                delegate?.select(value: "-1", tag: r,type: "DIS")
            }
        }
        
        //txtOOS.text = data[0]
        
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return data[row]
    }

}
