//
//  FileUploader.swift
//  NTLApp
//
//  Created by Tripsdoc on 16/08/23.
//

import Foundation
import UIKit

@objc protocol FileUploaderListener {
    func onError()
    func onFinish(response: Array<String>)
    func onProgressUpdate(currentIndexFile: Int, totalFile: Int, location: String)
}

class FileUploader {
    var mapImage = Array<String>()
    var photoNumber: String = ""
    var containerID: String = ""
    var uploadIndex: Int = -1
    var mode = 0
    var responses: Array<String>!
    var urlSession: URLSessionDataTask!
    var isCancel = false
    weak var delegate : FileUploaderListener? = nil
    
    public func uploadFiles(containerID: String, photoNumber: String, mode: Int, mapImage: Array<String>) {
        self.mapImage = mapImage
        self.mode = mode
        self.photoNumber = photoNumber
        self.containerID = containerID
        self.uploadIndex = -1
        responses = Array<String>()
        uploadNext()
    }
    
    public func cancelUpload() {
        isCancel = true
    }
    
    func uploadNext() {
        if !self.mapImage.isEmpty {
            uploadIndex += 1
            if uploadIndex < self.mapImage.count {
                uploadSingleFile(index: uploadIndex)
            } else {
                self.delegate?.onFinish(response: self.responses)
            }
        } else {
            self.delegate?.onFinish(response: self.responses)
        }
    }
    
    func uploadSingleFile(index: Int) {
        var token = ""
        if userPreference.object(forKey: ntlToken) != nil {
            token = "Bearer " + (userPreference.string(forKey: ntlToken) ?? "")
        }
        if let image = FileUtil.sharedInstance.getImage(fileName: self.mapImage[index]) {
            let newImage = resizeImage(image: image, targetSize: CGSize.init(width: 1024, height: 768))
            let imageData = newImage.jpegData(compressionQuality: 0.75)!
            var request: MultipartFormDataRequest!
            if mode == 0 || mode == 2 {
                request = MultipartFormDataRequest(url: URL(string: BaseURL + "PhotoList/UploadPhotoContainer")!, token: token)
            } else {
                request = MultipartFormDataRequest(url: URL(string: BaseURL + "PhotoList/UploadPhotoCargo")!, token: token)
            }
            
            request.addTextField(named: "ContainerId", value: containerID)
            if mode == 1 {
                request.addTextField(named: "PhotoNo", value: photoNumber)
            }
            request.addDataField(named: "PhotoFile", data: imageData, mimeType: "img/jpeg")
            self.urlSession = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                do {
                    if data != nil {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Any {
                            let object = json as! Dictionary<String, AnyObject>
                        }
                        self.delegate?.onProgressUpdate(currentIndexFile: self.uploadIndex, totalFile: self.mapImage.count, location: self.mapImage[index])
                        if !self.isCancel {
                            self.uploadNext()
                        }
                    } else {
                        self.delegate?.onError()
                    }
                } catch {
                    self.delegate?.onError()
                }
            })
            urlSession.resume()
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension URLSession {
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}

