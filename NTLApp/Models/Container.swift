//
//  Container.swift
//  NTLApp
//
//  Created by Tripsdoc on 11/08/23.
//

import Foundation
struct Container: Identifiable, Decodable {
    var id: Int
    var containerNumber: String
    var unStuffOrStuffDateText: String?
    var statusText: String?
    var processType: ProcessType?
    var photoMain: PhotoMain
    
    struct Cargo: Decodable {
        var id: String
        var cargoNumber: String
        var photoMain: PhotoMain
    }
}

struct ProcessType: Decodable {
    var id: String
    var codeName: String
}

struct PhotoMain: Decodable {
    var id: String
    var photoList: [Photo]
    
    struct Photo: Decodable {
        var id: String
        var photoName: String
        var photoPath: String
    }
}
