//
//  FileUtil.swift
//  NTLApp
//
//  Created by Tripsdoc on 14/08/23.
//

import Foundation
import UIKit

class FileUtil: NSObject {
    static let sharedInstance = FileUtil()
    
    override init() {
        super.init()
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func listFilesFromDocumentsFolder() -> [String]?
    {
        let fileMngr = FileManager.default;

        // Full path to documents directory
        let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/comhupsooncheongntl"

        // List all contents of directory and return as [String] OR nil if failed
        return try? fileMngr.contentsOfDirectory(atPath:docs)
    }
    
    func createDirectory(){
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("comhupsooncheongntl")
        if !fileManager.fileExists(atPath: paths){
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func removeTempImages() {
        let fileManager = FileManager.default
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let tempDirPath = dirPath + "/comhupsooncheongntl"
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: tempDirPath)
            for path in directoryContents {
                let fullPath = tempDirPath + "/" + path
                try fileManager.removeItem(atPath: fullPath)
            }
        } catch {
            print(error)
        }
    }
    
    func getImage(fileName: String) -> UIImage? {
        let fileManager = FileManager.default
        let imagePath = (FileUtil.sharedInstance.getDirectoryPath() as NSString).appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)!
        } else {
            return nil
        }
    }
    
    func resizeImageToCenter(image: UIImage) -> UIImage {
        let size = CGSize(width: 100, height: 100)

        // Define rect for thumbnail
        let scale = max(size.width/image.size.width, size.height/image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let x = (size.width - width) / CGFloat(2)
        let y = (size.height - height) / CGFloat(2)
        let thumbnailRect = CGRect.init(x: x, y: y, width: width, height: height)

        // Generate thumbnail from image
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: thumbnailRect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail!
    }
}
