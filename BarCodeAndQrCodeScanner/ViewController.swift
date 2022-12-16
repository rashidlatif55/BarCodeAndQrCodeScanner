//
//  ViewController.swift
//  BarCodeScanerPDF417
//
//  Created by Rashid Latif on 15/12/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

// MARK: - Actions
extension ViewController {
    @IBAction private func generateAction(_ sender: UIButton){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GenerateViewController") as! GenerateViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func scanAction(_ sender: UIButton){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


protocol Alert {}

extension Alert{
    public typealias alternateAction = () -> Void
    func showAlert(title: String, message: String = "", buttonTitle: String = "Start scanning again", completion: alternateAction? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: {_ in
              completion?()
            }))
        
            guard let window : UIWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {return}
            var presentVC = window.rootViewController
            while let next = presentVC?.presentedViewController {
                presentVC = next
            }
            presentVC?.present(alert, animated: true, completion: nil)
        }
    }
}
