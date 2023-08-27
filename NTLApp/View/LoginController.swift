//
//  LoginController.swift
//  NTLApp
//
//  Created by Tripsdoc on 27/08/23.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var emailField: TintTextField!
    @IBOutlet weak var passwordField: TintTextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var BGHeader: UIView!
    @IBOutlet weak var viewLogin: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    var spinner: ProgressViewController!
    
    func setupView() {
        BGHeader.layer.cornerRadius = 15
        BGHeader.clipsToBounds = true
        BGHeader.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        viewLogin.layer.cornerRadius = 15
        viewLogin.clipsToBounds = true
        
        emailField.layer.cornerRadius = 10
        emailField.clipsToBounds = true
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.systemTeal.cgColor
        
        passwordField.layer.cornerRadius = 10
        passwordField.clipsToBounds = true
        passwordField.layer.borderWidth = 1
        passwordField.layer.borderColor = UIColor.systemTeal.cgColor
        
        emailField.tintColor = UIColor.systemTeal
        emailField.setupTintColor()
        
        passwordField.tintColor = UIColor.systemTeal
        passwordField.setupTintColor()
    }
    
    @IBAction func doLogin(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        if (email != "" && password != "") {
            showProgress()
            var token = ""
            if userPreference.object(forKey: ntlToken) != nil {
                token = userPreference.string(forKey: ntlToken) ?? ""
            }
            guard let url = URL(string: "http://192.168.40.80:9133/api/NTLWebAPI/Account/Login") else { fatalError("Missing URL") }
            var request = URLRequest(url: url)
            request.setValue(token, forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "email": email,
                "password": password
            ]
            print(parameters)
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    self.hideProgress()
                    print("Request error : ", error)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {return}
                    if response.statusCode == 200 {
                        guard let data = data else {return}
                        DispatchQueue.main.async {
                            do {
                                let decodeLogin = try JSONDecoder().decode(LoginData.self, from: data)
                                userPreference.set(decodeLogin.fullName, forKey: ntlUserName)
                                self.getBearerToken()
                            } catch let error{
                                print(error)
                                self.hideProgress()
                            }
                        }
                    } else {
                        self.hideProgress()
                    }
            }
            dataTask.resume()
        }
    }
    
    func getBearerToken() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        if (email != "" && password != "") {
            showProgress()
            var token = ""
            if userPreference.object(forKey: ntlToken) != nil {
                token = userPreference.string(forKey: ntlToken) ?? ""
            }
            guard let url = URL(string: "http://192.168.40.80:9133/api/NTLWebAPI/Account/BearerToken") else { fatalError("Missing URL") }
            var request = URLRequest(url: url)
            request.setValue(token, forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "email": email,
                "password": password
            ]
            print(parameters)
            let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
                self.hideProgress()
                if let error = error {
                    self.hideProgress()
                    print("Request error : ", error)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {return}
                    if response.statusCode == 200 {
                        guard let data = data else {return}
                        DispatchQueue.main.async {
                            do {
                                self.hideProgress()
                                let decodeLogin = try JSONDecoder().decode(TokenData.self, from: data)
                                userPreference.set(decodeLogin.token, forKey: ntlToken)
                                OperationQueue.main.addOperation {
                                    var mainCtrl: ViewController
                                    if #available(iOS 13.0, *) {
                                        mainCtrl = self.storyboard?.instantiateViewController(identifier: "mainCtrl") as! ViewController
                                    } else {
                                        mainCtrl = self.storyboard?.instantiateViewController(withIdentifier: "mainCtrl") as! ViewController
                                    }
                                    UIApplication.shared.windows.first?.rootViewController = mainCtrl
                                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                                }
                            } catch let error{
                                print(error)
                                self.hideProgress()
                            }
                        }
                    } else {
                        self.hideProgress()
                    }
            }
            dataTask.resume()
        }
    }
    
    func showProgress() {
        spinner = ProgressViewController(message: "Loading")
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }
    
    func hideProgress() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spinner.willMove(toParent: nil)
            self.spinner.view.removeFromSuperview()
            self.spinner.removeFromParent()
        }
    }
}
