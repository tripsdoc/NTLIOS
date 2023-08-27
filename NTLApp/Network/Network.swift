//
//  Network.swift
//  NTLApp
//
//  Created by Tripsdoc on 11/08/23.
//

import Foundation
import CoreLocation

@available(iOS 13.0, *)
class Network: ObservableObject {
    @Published var container: [Container] = []
    @Published var currentContainer: Container!
    
    func getContainer() {
        guard let url = URL(string: "http://192.168.40.80:9133/api/ntl/Container/Get") else { fatalError("Missing URL") }
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error : ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {return}
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    DispatchQueue.main.async {
                        do {
                            let decodeContainer = try JSONDecoder().decode([Container].self, from: data)
                            self.container = decodeContainer
                        } catch let error {
                            print("Error decoding: ", error)
                        }
                    }
                }
        }
        dataTask.resume()
    }
    
    func getContainerID(id: String) {
        guard let url = URL(string: "http://192.168.40.80:9133/api/ntl/Container/Get/" + id) else { fatalError("Missing URL") }
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error : ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {return}
                if response.statusCode == 200 {
                    guard let data = data else {return}
                    DispatchQueue.main.async {
                        do {
                            let decodeContainer = try JSONDecoder().decode(Container.self, from: data)
                            self.currentContainer = decodeContainer
                        } catch let error {
                            print("Error decoding: ", error)
                        }
                    }
                }
        }
        dataTask.resume()
    }
}
