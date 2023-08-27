//
//  ContainerDetailController.swift
//  NTLApp
//
//  Created by Tripsdoc on 15/08/23.
//

import UIKit

class ContainerDetailController: UIViewController {

    @IBOutlet weak var BGHeader: UIView!
    @IBOutlet weak var FGHeader: UIView!
    
    @IBOutlet weak var layoutContainer: UIView!
    @IBOutlet weak var containerLabel: UILabel!
    @IBOutlet weak var detailsSec: UIView!
    
    @IBOutlet weak var cargoBtn: UIButton!
    @IBOutlet weak var containerBtn: UIButton!
    @IBOutlet weak var completeBtn: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    var containerNumber: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        containerLabel.text = containerNumber
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
        
        layoutContainer.layer.cornerRadius = 15
        layoutContainer.clipsToBounds = true
        layoutContainer.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        
        detailsSec.layer.cornerRadius = 15
        detailsSec.clipsToBounds = true
        detailsSec.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        
        cargoBtn.layer.cornerRadius = 15
        cargoBtn.clipsToBounds = true
        cargoBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        
        containerBtn.layer.cornerRadius = 15
        containerBtn.clipsToBounds = true
        containerBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        
        completeBtn.layer.cornerRadius = 15
        completeBtn.clipsToBounds = true
        completeBtn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]

        BGHeader.layer.cornerRadius = 15
        BGHeader.clipsToBounds = true
        BGHeader.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    
    @IBAction func didCargoBtnClick(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let cameraCtrl = self.storyboard?.instantiateViewController(identifier: "cameraCtrl") as! CameraViewController
            cameraCtrl.modalPresentationStyle = .fullScreen
            cameraCtrl.containerNumber = containerNumber
            cameraCtrl.imageType = "Cargo"
            self.present(cameraCtrl, animated: true, completion: nil)
        } else {
            let cameraCtrl = self.storyboard?.instantiateViewController(withIdentifier: "cameraCtrl") as! CameraViewController
            cameraCtrl.containerNumber = containerNumber
            cameraCtrl.imageType = "Cargo"
            self.present(cameraCtrl, animated: true, completion: nil)
        }
    }
    
    @IBAction func didContainerBtnClick(_ sender: Any) {
    }
    
    
    @IBAction func didCompleteBtnClick(_ sender: Any) {
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
