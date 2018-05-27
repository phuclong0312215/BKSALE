//
//  function.swift
//  SkyWorth
//
//  Created by HappyDragon on 2/24/16.
//  Copyright © 2016 acacy. All rights reserved.
//

import UIKit
import AssetsLibrary
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
enum DateFormatType: String {
    /// Time
    case time = "HH:mm:ss"
    
    /// Date with hours
    case dateWithTime = "yyyy-MM-dd HH:mm:ss"
    
    /// Date
    case date = "yyyy-MM-dd"
}
extension NSObject {
    
    /// Convert String to Date
    func convertToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatType.date.rawValue // Your date format
        let serverDate: Date = dateFormatter.date(from: dateString)! // according to date format your date string
        return serverDate
    }
}
var TimeZoneName:String = "Asia/Ho_Chi_Minh"
extension Date
{
    func hour() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
       let components = (calendar as NSCalendar).components([.minute,.month,.year,.day,.hour,.second], from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    func month() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.minute,.month,.year,.day,.hour,.second], from: self)
        let month = components.month
        
        //Return Hour
        return month!
    }
    
    func year() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.minute,.month,.year,.day,.hour,.second], from: self)
        let year = components.year
        
        //Return Hour
        return year!
    }

    func minute() -> Int
    {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.minute,.month,.year,.day,.hour,.second], from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    func toIntShortDate() -> Int
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyMMdd"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        return Int(timeString)!
    }
    func toString() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        return timeString
    }
    func to() -> Int
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyMMdd"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        return Int(timeString)!
    }
    
    func toLongDate() ->  String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString

    }
    func toImageName(_ empCode:String) ->  String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        var timeString = formatter.string(from: self)
        timeString=empCode+"_IMAGE_"+String(toIntShortDate())+"_"+timeString
        //Return Short Time String
        return timeString

        
    }
    func toLongTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
    func toShortTimeString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }

    func toLongTimeStringUpload() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        let timeString = formatter.string(from: self)
        
        //Return Short Time String
        return timeString
    }
    
}
class Function {
  
    static func Message(_ title:String,message:String){
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    static func Message(_ contoller:UIViewController, title:String,message:String,handler:@escaping (UIAlertAction)->Void){
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: handler))
        contoller.present(alert, animated: true, completion: nil)
    }
    static func resizeImage(_ image: UIImage, newWidth: CGFloat,newHeight:CGFloat) -> UIImage {
        var newHeight = newHeight
        
        let scale = newWidth / image.size.width
        if newHeight == 0{
            newHeight = image.size.height * scale
        }
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func getImageFromPath(_ path: String, onComplete:@escaping ((_ image: UIImage?) -> Void)) {
        let assetsLibrary = ALAssetsLibrary()
        let url = URL(string: path)!
        assetsLibrary.asset(for: url, resultBlock: { (asset) -> Void in
            if((asset) != nil){
                onComplete(UIImage(cgImage: (asset?.defaultRepresentation().fullResolutionImage().takeUnretainedValue())!))
            }
            else{
                onComplete(nil)
            }
            }, failureBlock: { (error) -> Void in
                onComplete(nil)
        })
    }

    func fixOrientation(_ image: UIImage) -> UIImage {
        // No-op if the orientation is already correct
        if (image.imageOrientation == UIImageOrientation.up) { return image; }
        
        //println(image.imageOrientation)
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (image.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case .up, .upMirrored:
            break
        }
        
        switch (image.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: image.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up, .down, .left, .right:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: (image.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (image.cgImage?.colorSpace!)!, bitmapInfo: (image.cgImage?.bitmapInfo.rawValue)!)
        
        ctx?.concatenate(transform);
        
        switch (image.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
            break
            
        default:
            ctx?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx?.makeImage()
        let img = UIImage(cgImage: cgimg!)
        
        return img
    }
    static func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    static func fileInDocumentsDirectory(_ filename: String) -> String {
        
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
        
    }
    
    static func sqliteGetString(_ state:OpaquePointer,column:Int32)-> String{
        
        let rowData1=sqlite3_column_text(state, column)
        var fieldValue1 = ""
        if rowData1 != nil {
            
            // print(rowData1)
            fieldValue1 = String(cString: rowData1!)
            // fieldValue1 = String(CStr : UnsafePointer<CChar>(rowData1!))
            // print(fieldValue1)
        }
        else {
            fieldValue1=""
        }
        
        return fieldValue1
        
    }
    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    static func getDateFormater() -> DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
        return dateFormatter
    }
    static func checkTime(_ controller:UIViewController, acess_token:String, handle: @escaping (Date) ->Void,errorHandle: @escaping ()-> Void){
        do{
            let task = Http().post("http://beko.spiral.com.vn:1000/time.ashx",function:"TIME",acess_token:acess_token){
                data, error in
                
                if (data != nil){
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
                        dateFormatter.timeZone = NSTimeZone(name: TimeZoneName)! as TimeZone
                        let _date = json!["Content"] as! String
                        guard let date = dateFormatter.date(from: _date) else {
                            fatalError("ERROR: Date conversion failed due to mismatched format.")
                        }
                        print(date)
                        handle(date);
                    } catch {
                        if(errorHandle != nil){
                            errorHandle()
                        }
                        Function.Message(controller,title:"Thông báo", message: "ERROR: Date conversion failed due to mismatched format."){action in
                            
                        }
                    }
                }
                else if(error != nil){
                    if(errorHandle != nil){
                        errorHandle()
                    }
                    Function.Message(controller,title:"Thông báo", message: "Không kết nối được với máy chủ. Vui lòng mở Wifi/3G và thực hiện lại."){
                        action in
                        self.checkTime(controller,acess_token: acess_token,handle: handle,errorHandle:errorHandle)
                    }
                }
                
            }
            if(task.error != nil)
            {
                if(errorHandle != nil){
                    errorHandle()
                }
                Function.Message(controller,title:"Thông báo", message: "Không kết nối được với máy chủ. Vui lòng mở Wifi/3G và thực hiện lại"){
                    action in
                    self.checkTime(controller,acess_token: acess_token,handle: handle,errorHandle:errorHandle)
                }
            }
        }
        catch{
            if(errorHandle != nil){
                errorHandle()
            }
            Function.Message(controller,title:"Thông báo", message: "Không kết nối được với máy chủ. Vui lòng mở Wifi/3G và thực hiện lại"){
                action in
                self.checkTime(controller,acess_token: acess_token,handle: handle,errorHandle:errorHandle)
            }
        }
    }
}
