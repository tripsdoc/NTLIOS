//
//  CameraViewController.swift
//  NTLApp
//
//  Created by Tripsdoc on 14/08/23.
//

import UIKit
import AVFoundation
import CoreMotion
import AssetsLibrary

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UICollectionViewDelegate, UICollectionViewDataSource, ProgressDelegate, FileUploaderListener {
    
    private var captureSession = AVCaptureSession()
    private var mainCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?
    private var currentDevice: AVCaptureDevice?
    private var imageDialog: UIAlertController?
    
    private var photoOutput: AVCapturePhotoOutput?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    private var isVideoMode: Bool = false
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var changeCameraBtn: UIButton!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    var spinner: ProgressViewController!
    var progressBar: ProgressAlert!
    var uploader = FileUploader()
    var containerNumber: String = ""
    var imageType: String = ""
    var countImage = 0
    
    var mapImage: Array<UIImage> = Array<UIImage>()
    var mapLocation: Array<String> = Array<String>()
    var isFinishedTakePhoto = true
    var orientationLast = UIInterfaceOrientation(rawValue: 0)
    var motionManager: CMMotionManager?

    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMotionManager()
        imageCollection.delegate = self
        imageCollection.dataSource = self
        imageCollection.backgroundView = nil
        imageCollection.backgroundColor = UIColor.clear
        
        doneBtn.isEnabled = false
        doneBtn.tintColor = UIColor.clear
        
        setupCaptureSession()
        setupDevice()
        setupIOs()
        setupPreviewLayer()
        captureSession.startRunning()
        setButtonImage()
        cameraBtn.isExclusiveTouch = true
        cameraBtn.isMultipleTouchEnabled = false
        
        progressBar = ProgressAlert(title: "Uploading", delegate: self)
        FileUtil.sharedInstance.createDirectory()
    }
    
    func setButtonImage() {
        if let cameraImage = UIImage(named: "camera-ios") {
            let tintableImage = cameraImage.withRenderingMode(.alwaysTemplate)
            cameraBtn.setImage(tintableImage, for: .normal)
        }
        if let changeCameraImage = UIImage(named: "change-camera") {
            let tintableImage = changeCameraImage.withRenderingMode(.alwaysTemplate)
            changeCameraBtn.setImage(tintableImage, for: .normal)
        }
        changeCameraBtn.tintColor = UIColor.white
        cameraBtn.tintColor = UIColor.white
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnClick(_ sender: Any) {
        var photoNumber = "0"
        var mode = 0
        let dialog = UIAlertController(title: "Confirmation", message: "Confirm upload image?", preferredStyle: UIAlertController.Style.alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.progressBar.setProgress(0)
            self.progressBar.present(from: self)
            self.uploader = FileUploader()
            self.uploader.delegate = self
            self.uploader.uploadFiles(containerNumber: self.containerNumber, photoNumber: photoNumber, mode: mode, mapImage: self.mapLocation)
        }))
        dialog.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        present(dialog, animated: true, completion: nil)
    }
    
    func initializeMotionManager() {
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.2
        motionManager?.gyroUpdateInterval = 0.2
        motionManager?.startAccelerometerUpdates(to: (OperationQueue.current)!, withHandler: {
            (accelerometerData, error) -> Void in
            if error == nil {
                self.outputAccelertionData((accelerometerData?.acceleration)!)
            } else {
                print("\(error!)")
            }
        })
    }
    
    func outputAccelertionData(_ acceleration: CMAcceleration) {
        var orientationNew: UIInterfaceOrientation
        if acceleration.x >= 0.75 {
            orientationNew = .landscapeLeft
        }
        else if acceleration.x <= -0.75 {
            orientationNew = .landscapeRight
        }
        else if acceleration.y <= -0.75 {
            orientationNew = .portrait
        }
        else if acceleration.y >= 0.75 {
            orientationNew = .portraitUpsideDown
        }
        else {
            return
        }

        if orientationNew == orientationLast {
            return
        }
        orientationLast = orientationNew
    }
    
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        
        let devices = deviceDiscoverySession.devices
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                backCamera = device
            }
        }
        
        currentDevice = mainCamera
    }
    
    func setupIOs() {
        let captureDeviceInput = try! AVCaptureDeviceInput(device: currentDevice!)
        captureSession.addInput(captureDeviceInput)
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
        captureSession.addOutput(photoOutput!)
    }
    
    func setupPreviewLayer() {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        DispatchQueue.main.async {
            self.cameraPreviewLayer?.frame = self.previewView.bounds
        }
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewView.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraPreviewLayer?.frame = self.previewView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.captureSession.startRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let image = UIImage(data: imageData)
            var newImage: UIImage? = nil
            if currentDevice == mainCamera {
                switch orientationLast {
                case .portraitUpsideDown:
                    newImage = image!.rotate(radians: .pi)
                case .landscapeLeft:
                    newImage = image!.rotate(radians: .pi/2)
                case .landscapeRight:
                    newImage = image!.rotate(radians: .pi * 1.5)
                default:
                    newImage = image
                }
            } else {
                switch orientationLast {
                case .portraitUpsideDown:
                    newImage = image!.rotate(radians: .pi)
                case .landscapeLeft:
                    newImage = image!.rotate(radians: .pi * 1.5)
                case .landscapeRight:
                    newImage = image!.rotate(radians: .pi/2)
                default:
                    newImage = image
                }
            }
            
            let textToAdd = getDate(modifier: 0, format: "yyyy-MM-dd HH:mm:ss")
            let imageText = addTextToImage(drawText: textToAdd, inImage: newImage!, atPoint: CGPoint(x: 20, y: 20))
            self.countImage += 1
            saveImageDocumentDirectory(image: imageText)
        } else {
            cameraBtn.isEnabled = true
        }
    }
    
    func addTextToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.green
        print("Image Size : ")
        print(image.size)
        let textSize = image.size.width / 40
        let textFont = UIFont(name: "Helvetica Bold", size: textSize)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor
        ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func saveImageDocumentDirectory(image: UIImage){
        let fileName = "comhupsooncheongntl/_" + imageType + "_" + getDate(modifier: 0, format: "yMdHms") + ".jpg"
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
        let imageData = image.jpegData(compressionQuality: 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        
        OperationQueue.main.addOperation {
            if let image = FileUtil.sharedInstance.getImage(fileName: fileName) {
                let resized = FileUtil.sharedInstance.resizeImageToCenter(image: image)
                self.mapImage.append(resized)
                self.mapLocation.append(fileName)
                if self.mapImage.count > 0 {
                    self.doneBtn.isEnabled = true
                    self.doneBtn.tintColor = UIColor.white
                }
                self.imageCollection.reloadData {
                    self.cameraBtn.isEnabled = true
                }
            } else {
                print(self.imageType)
                print("Cant get file")
            }
        }
    }
    
    @IBAction func didTakePhoto(_ sender: Any) {
        self.cameraBtn.isEnabled = false
        isFinishedTakePhoto = false
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        settings.isHighResolutionPhotoEnabled = false
        settings.flashMode = .auto
        photoOutput?.isHighResolutionCaptureEnabled = false
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func didChangeCamera(_ sender: Any) {
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        captureSession.removeInput(currentInput!)
        if currentDevice == backCamera {
            currentDevice = mainCamera
        } else {
            currentDevice = backCamera
        }
        let captureDeviceInput = try! AVCaptureDeviceInput(device: currentDevice!)
        captureSession.addInput(captureDeviceInput)
        captureSession.commitConfiguration()
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
    
    func onProgressCanceled() {
        uploader.cancelUpload()
        OperationQueue.main.addOperation {
            self.imageCollection.reloadData()
        }
    }
    
    func onError() {
        OperationQueue.main.addOperation {
            self.progressBar.dismiss(completion: nil)
            let dialog = UIAlertController(title: "An error occured", message: "Oops, something went wrong", preferredStyle: UIAlertController.Style.alert)
            dialog.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(dialog, animated: true, completion: nil)
        }
    }
    
    func onFinish(response: Array<String>) {
        OperationQueue.main.addOperation {
            self.progressBar.setProgress(1.0)
            self.progressBar.dismiss(completion: nil)
            self.mapLocation.removeAll()
            self.mapImage.removeAll()
            self.imageCollection.reloadData()
            self.doneBtn.isEnabled = false
            self.doneBtn.tintColor = UIColor.clear
            self.imageDialog = UIAlertController(title: "Image Uploaded", message: "Image uploaded successfully", preferredStyle: UIAlertController.Style.alert)
            self.imageDialog!.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            self.present(self.imageDialog!, animated: true, completion: nil)
        }
    }
    
    func onProgressUpdate(currentIndexFile: Int, totalFile: Int, location: String) {
        let progress = Float(currentIndexFile)/Float(totalFile)
        DispatchQueue.main.async {
            if let locationIndex = self.mapLocation.firstIndex(of: location) {
                self.mapImage.remove(at: locationIndex)
                self.mapLocation.remove(at: locationIndex)
                self.imageCollection.reloadData()
                self.imageCollection.setContentOffset(CGPoint.zero, animated: false)
                self.progressBar.setProgress(progress)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            let image = mapImage[indexPath.row]
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.actionDelete))
            cell.imageView.image = image
            cell.crossMarkView.index = indexPath.row
            cell.crossMarkView.addGestureRecognizer(gesture)
            return cell
        }
        return UICollectionViewCell()
    }
    
    @objc func actionDelete(sender : UITapGestureRecognizer) {
        let dialog = UIAlertController(title: "Confirm Delete", message: "Are you sure want to delete pictures?", preferredStyle: UIAlertController.Style.alert)
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            guard let unwrappedView = sender.view as? CrossMark else { return }
            self.mapImage.remove(at: unwrappedView.index)
            self.mapLocation.remove(at: unwrappedView.index)
            if self.mapImage.isEmpty {
                self.doneBtn.isEnabled = false
                self.doneBtn.tintColor = UIColor.clear
            }
            self.imageCollection.reloadData()
        }))
        dialog.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        present(dialog, animated: true, completion: nil)
    }

}

extension UICollectionView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
                    { _ in completion() }
    }
}
