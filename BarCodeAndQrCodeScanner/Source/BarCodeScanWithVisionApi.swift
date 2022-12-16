//
//  BarCodeScanWithVisionApi.swift
//  BarCodeScanerPDF417
//
//  Created by Rashid Latif on 16/12/2022.
//

import UIKit
import Vision
import AVFoundation

class BarCodeScanWithVisionApi:NSObject, Alert{
    var captureSession = AVCaptureSession()
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            self.showAlert(title: "Oops..!", message: error?.localizedDescription ?? "Error")
            return
        }
        self.processClassification(request)
    }
    
    var delegate:BarCodeScannerDelegate?
    
    override init() {
       
    }
    
    deinit{
        stop()
    }
    
    convenience init(view:UIView, delegate:BarCodeScannerDelegate){
        self.init()
        self.delegate = delegate
        checkPermissions()
        setupCameraLiveView(view: view)
    }
    
    func start(){
      DispatchQueue.global(qos: .background).async {
        self.captureSession.startRunning()
      }
    }
    
    func stop(){
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
        self.setTorchActive(isOn: false)
    }
}

extension BarCodeScanWithVisionApi{
    // MARK: - Camera
    private func checkPermissions() {
        // TODO: Checking permissions
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [self] granted in
                if !granted {
                    self.showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }
    
    private func setupCameraLiveView(view:UIView) {
        // TODO: Setup captureSession
        captureSession.sessionPreset = .hd1280x720
        
        // TODO: Add input
        let videoDevice = AVCaptureDevice
            .default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard
            let device = videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
            self.showAlert(title: "Oops..!", message: "There seems to be a problem with the camera on your device.")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        // TODO: Add output
        let captureOutput = AVCaptureVideoDataOutput()
        // TODO: Set video sample rate
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(captureOutput)
        
        configurePreviewLayer(view: view)
        
        // TODO: Run session
        start()
        
    }
    
    // MARK: - Vision
    func processClassification(_ request: VNRequest) {
        // TODO: Main logic
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                
                for barcode in barcodes {
                    guard
                        // TODO: Check for QR Code symbology and confidence score
                        let potentialQRCode = barcode as? VNBarcodeObservation,
                        //            potentialQRCode.symbology == .qr,
                        potentialQRCode.confidence > 0.9
                    else { return }
                    
                    self.stop()
                    self.delegate?.didReceiveBarCode(text: potentialQRCode.payloadStringValue ?? "Oops..! Error")
                }
            }
        }
    }
    
    
    private func configurePreviewLayer(view:UIView) {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = view.frame
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    
    private func showPermissionsAlert() {
        self.showAlert(title: "Oops..!", message: "There seems to be a problem with the camera on your device.")
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

extension BarCodeScanWithVisionApi:AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: Live Vision
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right)
        
        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }
}

