//
//  PopupWorkingViewController.swift
//  Aqua
//
//  Created by PHUCLONG on 1/22/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import UIKit
protocol didLoadDelegate{
    func loadDataRequest()
}
class PopupWorkingViewController: UIViewController {
    var delegate: didLoadDelegate?
    var model: WorkingModel? = nil
    @IBOutlet weak var txtWorkingDate: UITextField!
    var workingProvider = WorkingProvider()
    var ACCESS_TOKEN = ""
    var SHOPCODE = ""
    var WORKINGDATE = ""
    var EMPLOYEECODE = ""
    var lstShift = [ShiftModel]()
    var pickWorking = UIPickerView()
    var confirm = 0
    @IBOutlet weak var txtWorking: UITextField!
    
    @IBOutlet weak var viewEmp: UIView!
    @IBOutlet weak var contraintHeightEmp: NSLayoutConstraint!
    @IBOutlet weak var txtNote: UITextField!
    @IBOutlet weak var txtWorkingNew: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ACCESS_TOKEN = Preferences.get(key: "ACCESS_TOKEN")
        SHOPCODE = Preferences.get(key: "SHOPCODE")
        WORKINGDATE = Preferences.get(key: "WORKINGDATE")
       // POSITION = Preferences.get(key: "POSITION")
        EMPLOYEECODE = Preferences.get(key: "EMPLOYEECODE")
        
        if let m = model{
            SHOPCODE = m.shopcode
            EMPLOYEECODE = m.employeeCode
            confirm = 1
        }
        
        txtWorkingDate.text = WORKINGDATE
        txtWorkingDate.delegate = self
        txtWorkingNew.inputView = pickWorking
        
        pickWorking.delegate = self
        pickWorking.dataSource = self
       // self.popu
        self.showAnimate()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateUI(){
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {
            self.workingProvider.getShift(self.ACCESS_TOKEN, function: "SHIFT", workingDate: self.txtWorkingDate.text!, shopCode: self.SHOPCODE,empCode: self.EMPLOYEECODE,completionHandler: { (data , error ) in
                DispatchQueue.main.async {
                    if let lst = data {
                        self.lstShift = lst
                        let lstWorkingCurrent = lst.filter { $0.status == 1 }
                        if lstWorkingCurrent != nil && lstWorkingCurrent.count > 0{
                            self.txtWorking.text = lstWorkingCurrent[0].shift
                        }else{
                            Function.Message("Thông báo", message: "Chưa có lịch làm việc")
                            
                        }
                        self.pickWorking.reloadAllComponents()
                        self.view.endEditing(true)
                        
                    }else{
                        return
                    }
                    SVProgressHUD.dismiss()
                }
                
                
            })
        }
        

    }
    func saveWorkingToServer(model: WorkingModel){
        DispatchQueue.global(qos: .default).async {
            self.workingProvider.getList(self.ACCESS_TOKEN, function: "SAVE", model: model, completionHandler: { (data, error) in
                DispatchQueue.main.async {
                    if data != nil {
                        Function.Message("Thông báo", message: "Lưu thành công")
                        self.removeAnimate()
                        self.delegate?.loadDataRequest()
                    }else{
                        return
                    }
                    SVProgressHUD.dismiss()
                }

            })
        }
    }
    func showAnimate(){
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.view.alpha = 1
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (finished: Bool) in
            if(finished){
                self.updateUI()
            }
        }
        
       
    }
    func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }) { (finish: Bool) in
            if(finish){
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
    }
    
    @IBAction func closePopup(_ sender: Any) {
        removeAnimate()
    }

    @IBAction func saveWorking(_ sender: Any) {
        if let workingModel = getWorking() {
            saveWorkingToServer(model: workingModel)
        }
        
    }
    func getWorking() -> WorkingModel? {
        var model = WorkingModel()
        model.id = 0
//        if let result =  {
//            if result.
//            Function.Message("Thông báo", message: "Ngày phải lớn hơn hoặc bằng ngày hiện tại.")
//            return nil
//        }
        let result = NSCalendar.current.compare(Date(), to: convertToDate(dateString: txtWorkingDate.text!),
                                          toGranularity: .day)
        if result == .orderedDescending{
            Function.Message("Thông báo", message: "Ngày phải lớn hơn hoặc bằng ngày hiện tại.")
            return nil
        }
        if let str = txtWorking.text, !(txtWorking.text?.isEmpty)!{
            model.workingOld = str
        } else{
            Function.Message("Thông báo", message: "Chưa có lịch làm việc.")
            return nil
        }

        if let str = txtWorkingNew.text, !(txtWorkingNew.text?.isEmpty)!{
            model.working = str
        } else{
            Function.Message("Thông báo", message: "Bạn chưa chọn ca để chuyển.")
            return nil
        }
        if let str = txtNote.text, !(txtNote.text?.isEmpty)!{
            model.note = str
        }
        model.workingDate = txtWorkingDate.text!
        model.employeeCode = EMPLOYEECODE
        model.shopcode = SHOPCODE
        model.confirm = confirm
        return model
    }
    @IBAction func DateEditing(_ sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        sender.addDoneOnKeyboardWithTarget(self, action: #selector(PopupWorkingViewController.updateUI))
        datePickerView.addTarget(self, action: #selector(PopupWorkingViewController.datePickerValueChanged), for: 	UIControlEvents.valueChanged)
        
        
    }
    func datePickerValueChanged(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtWorkingDate.text = dateFormatter.string(from: sender.date)
        
    }

}

extension PopupWorkingViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
extension PopupWorkingViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lstShift.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //txtWorkingNew.text = lstShift[row].shift
        return lstShift[row].shift
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtWorkingNew.text = lstShift[row].shift
        
    }
}
