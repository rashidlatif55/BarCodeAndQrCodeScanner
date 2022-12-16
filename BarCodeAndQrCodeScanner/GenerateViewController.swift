// GenerateViewController
// Created by Rashid Latif on 15/12/2022.
// Email:- rashid.latif93@gmail.com
// https://stackoverflow.com/users/10383865/rashid-latif
// https://github.com/rashidlatif55

import UIKit

class GenerateViewController: UIViewController, Alert {
    
    // MARK: - Outlets
    @IBOutlet private weak var inputTextField:UITextField!
    @IBOutlet private weak var barcodeImageView:UIImageView!
    
    // MARK: - Variables
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

// MARK: - Actions
extension GenerateViewController {
    @IBAction private func generateBarCodeAction(_ sender: UIButton){
        guard let text = self.inputTextField.text, text != "" else {
            self.showAlert(title: "Oops..!", message: "Plesae enter text to generate barcode.",buttonTitle: "Ok")
            return
        }
        let image = BarCodeGenerator.PDF417Barcode(from: text)
        self.barcodeImageView.image = image
    }
}

// MARK: - Methods
extension GenerateViewController {
    
}

// MARK: - ViewModel
extension GenerateViewController {
    
}


