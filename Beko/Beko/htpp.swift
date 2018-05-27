//
//  htpp.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/4/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
extension String {
    var URLEncoded:String {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        let unreservedCharset = CharacterSet(charactersIn: unreservedChars)
        let encodedString = self.addingPercentEncoding(withAllowedCharacters: unreservedCharset)
        return encodedString ?? self
    }
}
class Http {
    
    init (){
        
    }
    func post(_ url: String,function:String,acess_token:String,completionHandler: @escaping (Data?, NSError?) -> ()) -> URLSessionTask {
        let URL = Foundation.URL(string: url)!
        let request = NSMutableURLRequest(url:URL)
        request.httpMethod = "POST"
        let body="access_token=\(acess_token.URLEncoded)&FUNCTION=\(function)"
        request.httpBody = body.data(using: String.Encoding.utf8);
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 180.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            DispatchQueue.main.async {
                guard data != nil else {
                    completionHandler(nil, error as NSError?)
                    return
                }
                
                completionHandler(data, nil)
            }
        }
        
        task.resume()
        
        return task
    }
    func postLogin(_ url: String,username:String,password:String,completionHandler: @escaping (Data?, NSError?) -> ()) -> URLSessionTask {
        let URL = Foundation.URL(string: url)!
        let request = NSMutableURLRequest(url:URL)
        request.httpMethod = "POST"
        let body="username=\(username)&password=\(password)"
        
        request.httpBody = body.data(using: String.Encoding.utf8);
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 180.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            DispatchQueue.main.async {
                guard data != nil else {
                    completionHandler(nil, error as NSError?)
                    return
                }
                
                completionHandler(data, nil)
            }
        }
        task.resume()
        
        return task
    }
    func uploadFiles(_ parameters: [String: String],URL_UploadImage: String,arrData: [Data],fileName: String,mimeType: String,completionHandler: @escaping (String?, String?) -> ()){
        requestSaveFile(parameters, URL_UploadImage: URL_UploadImage, arrData: arrData,fileName: fileName,mimeType: mimeType, completionHandler: completionHandler)
    }
    func requestSaveFile(_ parameters: [String: String],URL_UploadImage: String,arrData: [Data],fileName: String,mimeType: String,completionHandler: @escaping (String?, String?) -> ()){
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for i in 0 ..< arrData.count {
                //let imgData = UIImageJPEGRepresentation(arrImage[i], 1)!
                //multipartFormData.append(arrData[i], withName: "fileset",fileName: fileName, mimeType: "image/jpg")
                multipartFormData.append(arrData[i], withName: "fileset",fileName: fileName, mimeType: mimeType)
                
                
            }
            
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:URL_UploadImage)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseString { response in
                    completionHandler(response.result.value, nil)
                }
                
            case .failure(let encodingError):
                completionHandler(nil, encodingError.localizedDescription)
            }
        }
        
    }
    func uploadFilesWithType(_ parameters: [String: String],URL_UploadImage: String,arrData: [ImageModel],completionHandler: @escaping (String?, String?) -> ()){
        requestSaveFileWithType(parameters, URL_UploadImage: URL_UploadImage, arrData: arrData, completionHandler: completionHandler)
    }
    func requestSaveFileWithType(_ parameters: [String: String],URL_UploadImage: String,arrData: [ImageModel],completionHandler: @escaping (String?, String?) -> ()){
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for i in 0 ..< arrData.count {
                //let imgData = UIImageJPEGRepresentation(arrImage[i], 1)!
                //multipartFormData.append(arrData[i], withName: "fileset",fileName: fileName, mimeType: "image/jpg")
                multipartFormData.append(arrData[i].ImageData!, withName: "fileset",fileName: arrData[i].ImageType!, mimeType: arrData[i].MimeType!)
                
                
            }
            
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                         to:URL_UploadImage)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseString { response in
                    completionHandler(response.result.value, nil)
                }
                
            case .failure(let encodingError):
                completionHandler(nil, encodingError.localizedDescription)
            }
        }
        
    }
    
    func performRequest(_ method: HTTPMethod, requestURL: String, params: [String: AnyObject], comletion: @escaping (_ json: AnyObject?) -> Void) {
        
        Alamofire.request(requestURL, method: .get, parameters: params, headers: nil).responseJSON { (response:DataResponse<Any>) in
            //print(response)
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    // print("YOUR JSON DATA>>  \(response.data!)")
                    comletion(data as AnyObject?)
                    
                }
                break
                
            case .failure(_):
                print(response.result.error)
                // SVProgressHUD.dismiss()
                Function.Message("Thông báo", message: "Mạng không ổn đinh,vui lòng thử lại.")
                comletion(nil)
                break
                
            }
        }
    }

    
}
