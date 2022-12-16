//
//  BarCodeScaner.swift
//  BarCodeScanerPDF417
// Email:- rashid.latif93@gmail.com
// https://stackoverflow.com/users/10383865/rashid-latif
// https://github.com/rashidlatif55

import AVFoundation
import UIKit

protocol BarCodeScannerDelegate{
    func didReceiveBarCode(text:String)
}

class BarCodeScanner:NSObject, AVCaptureMetadataOutputObjectsDelegate, Alert{
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate:BarCodeScannerDelegate?
    var metadata : [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128, .upce, .itf14, .aztec]
//    var metadata : [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code39, .code93, .code128, .code39Mod43, .upce, .itf14, .dataMatrix, .aztec]
  
    override init() {
        
    }
    
    convenience init(view:UIView, delegate:BarCodeScannerDelegate){
        self.init()
        
        self.delegate = delegate
        
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
            showAlert(title: "Oops", message: "Device may not support scanning or check with your camera permissions", buttonTitle: "Ok")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = metadata
        } else {
            showAlert(title: "Oops", message: "Device may not support scanning or check with your camera permissions",buttonTitle: "Ok")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
    }
    
    func start(){
        if (captureSession?.isRunning == false) {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop(){
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            self.setTorchActive(isOn: false)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stop()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            print(readableObject.type)
            guard let stringValue = readableObject.stringValue else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            self.delegate?.didReceiveBarCode(text: stringValue)
        }
    }
    
    public func setTorchActive(isOn: Bool) {
        assert(Thread.isMainThread)
        
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              videoDevice.hasTorch, videoDevice.isTorchAvailable else {
            return
        }
        try? videoDevice.lockForConfiguration()
        videoDevice.torchMode = isOn ? .on : .off
        videoDevice.unlockForConfiguration()
    }
}
