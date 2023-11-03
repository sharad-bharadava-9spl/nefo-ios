//
//  QRScannerVC.swift
//  CCSMembersApp
//
//  Created by mac-18 on 30/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate{
    func getQRData(QRString: String)
}

class QRScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var scannerView: UIView!
    
    @IBOutlet weak var lblgoback: UILabel!
    @IBOutlet weak var lblAskFrnd: UILabel!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var delegate: QRCodeScannerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLanguage()
        self.navigationController?.navigationBar.isHidden = true
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.scannerView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.scannerView.layer.addSublayer(previewLayer)
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        
        
        DispatchQueue.global().async { [self] in
            captureSession.startRunning()
        }
        
    }
    
    func failed() {
        self.showAlert(title: "Error".localized, message: "Your device does not support scanning a code".localized)
        captureSession = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    //update fit camara in View
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = scannerView.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        
        //dismiss(animated: true)
    }
    
    func found(code: String) {
        self.navigationController?.popViewController(animated: true, completion: {
            self.delegate?.getQRData(QRString: code)
            print(code)
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    func setupLanguage() {
        self.lblAskFrnd.text = "msg_ask_your_friend_for_scan_qr".localized
        self.lblgoback.text = "Go Back".localized
        
    }
}


// MARK: - Button Actions
extension QRScannerVC {
    @IBAction func btnBack(_ sender: UIButton) {
        //self.dismiss(animated: true)
              
        self.navigationController?.popViewController(animated: true)
    }
}
