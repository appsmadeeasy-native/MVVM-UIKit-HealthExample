//
//  ManualEntryViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

class ManualEntryViewController: UIViewController {
    
    var contentType: String?

    override func loadView() {
        switch contentType {
//        case "Glucometer":
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                let childVC = UIHostingController(rootView: NewBGWSTMView())
//
//                self.addChild(childVC)
//                childVC.view.frame = self.view.bounds
//                self.view.addSubview(childVC.view)
//                childVC.didMove(toParent: self)
//
//                childVC.view.translatesAutoresizingMaskIntoConstraints = false
//
//                NSLayoutConstraint.activate([
//                    childVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
//                    childVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
//                    childVC.view.topAnchor.constraint(equalTo: self.view.topAnchor)
//                ])
//            }

//            let contentView: BGWSTMView = .init()
//            contentView.initialSetup(deviceType: contentType!)
//            contentView.closeManualEntryDelegate = self
//            view = contentView
        case "Blood Pressure":
            let contentView: PressureView = .init()
            contentView.closeManualEntryDelegate = self
            view = contentView
//        case "Weight Scale":
//            let contentView: BGWSTMView = .init()
//            contentView.initialSetup(deviceType: contentType!)
//            contentView.closeManualEntryDelegate = self
//            view = contentView
//        case "Thermometer":
//            let contentView: BGWSTMView = .init()
//            contentView.initialSetup(deviceType: contentType!)
//            contentView.closeManualEntryDelegate = self
//            view = contentView
        case "Pulse Oximeter":
            let contentView: OxygenView = .init()
            contentView.closeManualEntryDelegate = self
            view = contentView
        default:
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = contentType
    }
    
    @IBAction func exitManualEntry(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

extension ManualEntryViewController: CloseManualEntryDelegate {
    func didTapSaveButton() {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
