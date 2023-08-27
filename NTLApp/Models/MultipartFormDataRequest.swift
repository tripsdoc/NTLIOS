//
//  MultipartFormDataRequest.swift
//  NTLApp
//
//  Created by Tripsdoc on 16/08/23.
//

import Foundation

struct MultipartFormDataRequest {
    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    private var token = ""
    let url: URL
    
    init(url: URL, token: String) {
        self.url = url
        self.token = token
    }
    
    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }
    
    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }
    
    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }
    
    func setToken(token: String) {
        self.token = token
    }
    
    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()
        let fileName = "JPEG_\(getFileName()).jpg"
        fieldData.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
        fieldData.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        fieldData.append(data)
        fieldData.append("\r\n".data(using: String.Encoding.utf8)!)

        return fieldData as Data
    }
    
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        request.setValue(token, forHTTPHeaderField: "Authorization")
        return request
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension NSMutableData {
  func append(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
