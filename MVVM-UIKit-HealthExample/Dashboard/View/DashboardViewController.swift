//
//  DashboardViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/16/21.
//

import UIKit

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    private var mDeviceList = Array<Device>()
    private var mDevice: Device?
    private var mViewModel: DashboardViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check db files on simulator to view data
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveReloadNotification), name: Notification.Name("didReceiveReloadNotification"), object: nil)
        tableView.tableFooterView = UIView()
        
        mViewModel = DashboardViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        mDeviceList = mViewModel.getAllDevices()
        tableView.reloadData()
    }

    @objc func didReceiveReloadNotification(notification: Notification) {
        mDeviceList = mViewModel.getAllDevices()
        tableView.reloadData()
    }
    
    @objc func manualButtonPressed(sender: UIButton) {
        print(sender.tag)
        let device = mDeviceList[sender.tag]
        switch device.deviceType {
        case "Glucometer":
            let vc = UIStoryboard(name: "ManualEntry", bundle: nil).instantiateViewController(withIdentifier: "ManualEntryViewController") as? ManualEntryViewController
            vc?.contentType = "Glucometer"
            let navController = CustomNavigationController(rootViewController: vc!)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        case "Blood Pressure":
            let vc = UIStoryboard(name: "ManualEntry", bundle: nil).instantiateViewController(withIdentifier: "ManualEntryViewController") as? ManualEntryViewController
            vc?.contentType = "Blood Pressure"
            let navController = CustomNavigationController(rootViewController: vc!)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        case "Weight Scale":
            let vc = UIStoryboard(name: "ManualEntry", bundle: nil).instantiateViewController(withIdentifier: "ManualEntryViewController") as? ManualEntryViewController
            vc?.contentType = "Weight Scale"
            let navController = CustomNavigationController(rootViewController: vc!)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        case "Thermometer":
            let vc = UIStoryboard(name: "ManualEntry", bundle: nil).instantiateViewController(withIdentifier: "ManualEntryViewController") as? ManualEntryViewController
            vc?.contentType = "Thermometer"
            let navController = CustomNavigationController(rootViewController: vc!)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        case "Pulse Oximeter":
            let vc = UIStoryboard(name: "ManualEntry", bundle: nil).instantiateViewController(withIdentifier: "ManualEntryViewController") as? ManualEntryViewController
            vc?.contentType = "Pulse Oximeter"
            let navController = CustomNavigationController(rootViewController: vc!)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        default:
            return
        }
    }

    // MARK: - Navigation

    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        if (identifier == "BluetoothSegue") {
            let vc = UIStoryboard(name: "Bluetooth", bundle: nil).instantiateViewController(withIdentifier: "BluetoothViewController") as? BluetoothViewController
            vc?.setDevice(device: mDevice!)
            let navController = CustomNavigationController(rootViewController: vc!)

            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: false, completion: nil)
        }
    }

}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDeviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "deviceItemCell") as! DashboardTableViewCell
        
        let device = mDeviceList[indexPath.row]
        switch device.deviceType {
        case "Glucometer":
            cell.deviceIconIV.image = UIImage(named: "BGIcon")
            if (device.lastReadingValue1.count > 0) {
                cell.lastReadingValue.text = device.lastReadingValue1
                cell.readingScale.text = device.readingScale
                cell.lastReadingTimeStamp.text = device.lastReadingTimestamp
            }
            cell.readingType.text = "Blood Glucose"
        case "Blood Pressure":
            cell.readingScale.text = ""
            cell.deviceIconIV.image = UIImage(named: "BPIcon")
            if (device.lastReadingValue1.count > 0 && device.lastReadingValue2.count > 0) {
                cell.lastReadingValue.text = "\(device.lastReadingValue1)/\(device.lastReadingValue2) (\(device.lastReadingValue3))"
                cell.lastReadingTimeStamp.text = device.lastReadingTimestamp
            }
            cell.readingType.text = "Blood Pressure"
        case "Weight Scale":
            cell.deviceIconIV.image = UIImage(named: "WSIcon")
            if (device.lastReadingValue1.count > 0) {
                cell.lastReadingValue.text = device.lastReadingValue1
                cell.readingScale.text = device.readingScale
                cell.lastReadingTimeStamp.text = device.lastReadingTimestamp
            }
            cell.readingType.text = "Weight"
        case "Thermometer":
            cell.deviceIconIV.image = UIImage(named: "TMIcon")
            if (device.lastReadingValue1.count > 0) {
                cell.lastReadingValue.text = device.lastReadingValue1
                cell.readingScale.text = device.readingScale
                cell.lastReadingTimeStamp.text = device.lastReadingTimestamp
            }
            cell.readingType.text = "Temperature"
        case "Pulse Oximeter":
            cell.readingScale.text = ""
            cell.deviceIconIV.image = UIImage(named: "SPO2Icon")
            if (device.lastReadingValue1.count > 0 && device.lastReadingValue2.count > 0) {
                cell.lastReadingValue.text = device.lastReadingValue1 + device.readingScale + " (" + device.lastReadingValue2 + ")"
                cell.lastReadingTimeStamp.text = device.lastReadingTimestamp
            }
            cell.readingType.text = "Blood Oxygen"
        default:
            return cell
        }
        
        cell.manualButton.tag = indexPath.row
        cell.manualButton.addTarget(self, action: #selector(manualButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mDevice = mDeviceList[indexPath.row]
        performSegue(withIdentifier: "BluetoothSegue", sender: self)
    }
}
