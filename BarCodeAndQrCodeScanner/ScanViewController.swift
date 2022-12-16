// ScanViewController
// Created by Rashid Latif on 15/12/2022.
// Email:- rashid.latif93@gmail.com
// https://stackoverflow.com/users/10383865/rashid-latif
// https://github.com/rashidlatif55

import UIKit

class ScanViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var scanView:UIView!
    @IBOutlet private weak var startAgainButton:UIButton!
   
    // MARK: - Variables
//    lazy var scanner:BarCodeScanner = {
//        let sn = BarCodeScaner(view: self.scanView, delegate: self)
//        return sn
//    }()
//
    lazy var scanner:BarCodeScanWithVisionApi = {
        let sn = BarCodeScanWithVisionApi(view: self.scanView, delegate: self)
        return sn
    }()
    
    var receivedBarCode:String?{
        didSet{
            self.startAgainButton.isHidden = receivedBarCode == nil
        }
    }
    var isOnflash = false
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        receivedBarCode = nil
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.scanner.start()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scanner.stop()
    }
    
}

// MARK: - ScanViewController
extension ScanViewController:BarCodeScannerDelegate , Alert{
    func didReceiveBarCode(text: String) {
        self.receivedBarCode = text
        print(text)
        self.showAlert(title: "Scanned code", message: text) {
            DispatchQueue.main.async {
                self.scanner.start()
                self.receivedBarCode = nil
            }
        }
    }
    
    
}

// MARK: - Actions
extension ScanViewController {
    @IBAction private func startAgainAction(_ sender: UIButton){
        DispatchQueue.main.async {
            self.scanner.start()
            self.receivedBarCode = nil
        }
    }
    
    @IBAction private func flashAction(_ sender: UIBarButtonItem){
        isOnflash.toggle()
        scanner.setTorchActive(isOn: isOnflash)
    }
}
