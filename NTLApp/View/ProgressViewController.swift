//
//  ProgressViewController.swift
//  NTLApp
//
//  Created by Tripsdoc on 16/08/23.
//

import UIKit

class ProgressViewController: UIViewController {
    private let activityView = SpinnerViewController()
    
    init(message: String) {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        activityView.messageLabel.text = message
        view = activityView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpinnerViewController: UIView {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)
    var boundingBoxView = UIView(frame: CGRect.zero)
    var messageLabel = UILabel(frame: CGRect.zero)
    
    init () {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        boundingBoxView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        boundingBoxView.layer.cornerRadius = 12.0
        
        spinner.startAnimating()
        messageLabel.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.shadowColor = UIColor.black
        messageLabel.shadowOffset = CGSize.init(width: 0.0, height: 1.0)
        messageLabel.numberOfLines = 0
        
        addSubview(boundingBoxView)
        addSubview(spinner)
        addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        boundingBoxView.frame.size.width = 160.0
        boundingBoxView.frame.size.height = 160.0
        boundingBoxView.frame.origin.x = ceil((bounds.width / 2.0) - (boundingBoxView.frame.width / 2.0))
        boundingBoxView.frame.origin.y = ceil((bounds.height / 2.0) - (boundingBoxView.frame.height / 2.0))

        spinner.frame.origin.x = ceil((bounds.width / 2.0) - (spinner.frame.width / 2.0))
        spinner.frame.origin.y = ceil((bounds.height / 2.0) - (spinner.frame.height / 2.0))

        let messageLabelSize = messageLabel.sizeThatFits(CGSize.init(width: 160.0 - 20.0 * 2.0, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.frame.size.width = messageLabelSize.width
        messageLabel.frame.size.height = messageLabelSize.height
        messageLabel.frame.origin.x = ceil((bounds.width / 2.0) - (messageLabel.frame.width / 2.0))
        messageLabel.frame.origin.y = ceil(spinner.frame.origin.y + spinner.frame.size.height + ((boundingBoxView.frame.height - spinner.frame.height) / 4.0) - (messageLabel.frame.height / 2.0))
    }
}

protocol ProgressDelegate: class {
    func onProgressCanceled()
}

class ProgressAlert {

    private let alert: UIAlertController
    private var progressBar: UIProgressView

    init(title: String, delegate: ProgressDelegate?) {
        
        alert = UIAlertController(title: title, message: "",
                                  preferredStyle: .alert)
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.tintColor = .blue
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { alertAction in
            delegate?.onProgressCanceled()
        })
    }

    func present(from uivc: UIViewController) {
        
        uivc.present(alert, animated: true, completion: {
            
            let margin: CGFloat = 16.0
            let rect = CGRect(x: margin, y: 56.0,
                              width: self.alert.view.frame.width - margin * 2.0, height: 2.0)
            self.progressBar.frame = rect
            self.alert.view.addSubview(self.progressBar)
        })
    }

    func dismiss(completion: (() -> Void)?) {
        
        alert.dismiss(animated: true, completion: completion)
    }

    func setProgress(_ value: Float) {
        progressBar.setProgress(value, animated: true)
    }
}
