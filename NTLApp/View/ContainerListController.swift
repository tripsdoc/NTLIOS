//
//  ContainerListController.swift
//  NTLApp
//
//  Created by Tripsdoc on 11/08/23.
//

import UIKit
import SwiftUI
import CoreLocation

class ContainerListController: UIViewController {
    @IBOutlet weak var containerTable: UITableView!
    var container: [Container] = []
    var filter: [Container] = []
    var mode: String = "Import"
    var searching = false

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var BGHeader: UIView!
    @IBOutlet weak var FGHeader: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        containerTable.delegate = self
        containerTable.dataSource = self
        searchBar.delegate = self
        getContainer()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            navBar.standardAppearance = appearance
        } else {
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
        }
        
        FGHeader.backgroundColor = UIColor.clear

        searchBar.setMagnifyingGlassColorTo(color: UIColor.black)
        searchBar.setClearButtonColorTo(color: UIColor.gray)
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        searchBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        BGHeader.layer.cornerRadius = 15
        BGHeader.clipsToBounds = true
        BGHeader.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        containerTable.backgroundColor = UIColor.clear
        containerTable.backgroundView = nil
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getContainer() {
        var token = ""
        if userPreference.object(forKey: ntlToken) != nil {
            token = "Bearer " + (userPreference.string(forKey: ntlToken) ?? "")
        }
        guard let url = URL(string: BaseURL + "Container/Get") else { fatalError("Missing URL") }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
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
                            let rawFilter = self.container.filter({(container: Container) -> Bool in
                                var isSameMode = false
                                if container.processType?.codeName == self.mode {
                                    isSameMode = true
                                }
                                return container.statusText != "Completed" && isSameMode
                            })
                            self.filter = rawFilter
                            print(self.filter)
                            OperationQueue.main.addOperation {
                                self.containerTable.reloadData()
                            }
                        } catch let error {
                            print("Error decoding: ", error)
                        }
                    }
                }
        }
        dataTask.resume()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }

}

extension ContainerListController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let rawFilter = container.filter({(container: Container) -> Bool in
            var isSameMode = false
            if container.processType?.codeName == mode {
                isSameMode = true
            }
            return container.statusText != "Completed" && isSameMode
        })
        if searchText != "" {
            filter = rawFilter.filter({(container: Container) -> Bool in
                let numberSearch = container.containerNumber
                return numberSearch.lowercased().contains(searchText.lowercased())
            })
        } else {
            filter = rawFilter
        }
        
        searching = true
        containerTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filter.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "containerCell") as! ContainerCell
        cell.containerNumber.text = filter[indexPath.row].containerNumber
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var containerNumber = filter[indexPath.row].containerNumber
        if #available(iOS 13.0, *) {
            let detailCtrl = self.storyboard?.instantiateViewController(identifier: "containerDetailCtrl") as! ContainerDetailController
            detailCtrl.modalPresentationStyle = .fullScreen
            detailCtrl.containerNumber = containerNumber
            self.present(detailCtrl, animated: true, completion: nil)
        } else {
            let detailCtrl = self.storyboard?.instantiateViewController(withIdentifier: "containerDetailCtrl") as! ContainerDetailController
            detailCtrl.containerNumber = containerNumber
            self.present(detailCtrl, animated: true, completion: nil)
        }
    }
}

extension UISearchBar
{

    func setMagnifyingGlassColorTo(color: UIColor)
    {
        // Search Icon
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }

    func setClearButtonColorTo(color: UIColor)
    {
        // Clear Button
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let crossIconView = textFieldInsideSearchBar?.value(forKey: "clearButton") as? UIButton
        crossIconView?.setImage(crossIconView?.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        crossIconView?.tintColor = color
    }

    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
}
