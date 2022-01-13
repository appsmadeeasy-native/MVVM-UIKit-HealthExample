//
//  LaunchViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/22/21.
//

import UIKit

class LaunchViewController: UIViewController {

    private let homeImageView: UIImageView = {
        let homeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        homeImageView.image = UIImage(named: "LaunchLogo")
        return homeImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(homeImageView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLayoutSubviews()
        homeImageView.center = view.center
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
    
    private func animate() {
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.frame.size.width * 3
            let diffX = size - self.view.frame.size.width
            let diffY = self.view.frame.size.height - size
            
            self.homeImageView.frame = CGRect(
                x: -(diffX/2),
                y: diffY/2,
                width: size,
                height: size
            )
        })
        
        UIView.animate(withDuration: 1.5, animations: {
            self.homeImageView.alpha = 0
        }, completion: { done in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                let defaults = UserDefaults.standard
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
                if (defaults.bool(forKey: "IsSettings")) {
                    let dashboardViewController:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
                    let navigationController = CustomNavigationController(rootViewController: dashboardViewController)
                    self.view.window?.rootViewController = navigationController
                } else {
                    defaults.setValue(true, forKey: "IsSettings")
                    let settingsViewController:UIViewController = mainstoryboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                    settingsViewController.modalTransitionStyle = .coverVertical
                    settingsViewController.modalPresentationStyle = .fullScreen
                    self.present(settingsViewController, animated: false, completion: nil)
                }
            })
        })
    }

}
