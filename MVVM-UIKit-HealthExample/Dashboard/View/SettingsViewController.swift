//
//  SettingsViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/22/21.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var coreDataButton: UIButton!
    @IBOutlet weak var realmDBButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Apply radius to Popupview
        popUpView.layer.cornerRadius = 10
        popUpView.layer.masksToBounds = true
        
        acceptButton.layer.cornerRadius = 10
        coreDataButton.isSelected = true
    }
    
    @IBAction func acceptBtnAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        if (coreDataButton.isSelected) {
            defaults.setValue("coredata", forKey: "database")
        } else if (realmDBButton.isSelected) {
            defaults.setValue("realm", forKey: "database")
        }
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let dashboardViewController:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        let navigationController = CustomNavigationController(rootViewController: dashboardViewController)
        self.view.window?.rootViewController = navigationController
    }
    
    @IBAction func coreDataBtnAction(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            realmDBButton.isSelected = false
        }
    }
    
    @IBAction func realmDBBtnAction(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = true
            coreDataButton.isSelected = false
        }
    }
}
