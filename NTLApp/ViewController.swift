//
//  ViewController.swift
//  NTLApp
//
//  Created by Tripsdoc on 11/08/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var BGHeader: UIView!
    @IBOutlet weak var FGHeader: UIView!
    @IBOutlet weak var cardImport: UIView!
    @IBOutlet weak var cardExport: UIView!
    @IBOutlet weak var cardSendIn: UIView!
    
    @IBOutlet weak var layerImageImport: UIView!
    @IBOutlet weak var layerImageExport: UIView!
    @IBOutlet weak var layerImageSendIn: UIView!
    
    var mode = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGesture()
    }
    
    func setupGesture() {
        let actionImport = UITapGestureRecognizer(target: self, action: #selector(self.importBtnClicked))
        let actionExport = UITapGestureRecognizer(target: self, action: #selector(self.exportBtnClicked))
        let actionSendIn = UITapGestureRecognizer(target: self, action: #selector(self.sendInBtnClicked))
        
        self.cardImport.isUserInteractionEnabled = true
        self.cardImport.addGestureRecognizer(actionImport)
        
        self.cardExport.isUserInteractionEnabled = true
        self.cardExport.addGestureRecognizer(actionExport)
        
        self.cardSendIn.isUserInteractionEnabled = true
        self.cardSendIn.addGestureRecognizer(actionSendIn)
    }
    
    func setupView() {
        FGHeader.backgroundColor = UIColor.clear

        BGHeader.layer.cornerRadius = 15
        BGHeader.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        cardImport.layer.cornerRadius = 15
        cardImport.clipsToBounds = true
        cardImport.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        cardExport.layer.cornerRadius = 15
        cardExport.clipsToBounds = true
        cardExport.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        cardSendIn.layer.cornerRadius = 15
        cardSendIn.clipsToBounds = true
        cardSendIn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        layerImageImport.layer.cornerRadius = 15
        layerImageImport.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        layerImageExport.layer.cornerRadius = 15
        layerImageExport.layer.maskedCorners = [.layerMaxXMaxYCorner]
        
        layerImageSendIn.layer.cornerRadius = 15
        layerImageSendIn.layer.maskedCorners = [.layerMaxXMaxYCorner]
    }

    @objc func importBtnClicked(sender: UITapGestureRecognizer) {
        cardImport.showAnimation {
            self.mode = "Import"
            self.openListController()
        }
    }
    
    @objc func exportBtnClicked(sender: UITapGestureRecognizer) {
        cardExport.showAnimation {
            self.mode = "Export"
            self.openListController()
        }
    }
    
    @objc func sendInBtnClicked(sender: UITapGestureRecognizer) {
        cardSendIn.showAnimation {
            
        }
    }
    
    func openListController() {
        if #available(iOS 13.0, *) {
            let containerCtrl = self.storyboard?.instantiateViewController(identifier: "containerListCtrl") as! ContainerListController
            containerCtrl.modalPresentationStyle = .fullScreen
            containerCtrl.mode = self.mode
            self.present(containerCtrl, animated: true, completion: nil)
        } else {
            let containerCtrl = self.storyboard?.instantiateViewController(withIdentifier: "containerListCtrl") as! ContainerListController
            containerCtrl.mode = self.mode
            self.present(containerCtrl, animated: true, completion: nil)
        }
    }

}

