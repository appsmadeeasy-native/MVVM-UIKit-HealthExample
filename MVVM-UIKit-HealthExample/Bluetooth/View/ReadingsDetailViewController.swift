//
//  ReadingsDetailViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/25/21.
//

import UIKit

class ReadingsDetailViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var mViewModel: BluetoothViewModel?
    private var database: String?
    public var deviceType: String = ""
    var mReadingList: [Dictionary<String,String>]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        mReadingList?.sort(by: {($0["createdTime"]!) > $1["createdTime"]!})
        
        saveButton.layer.cornerRadius = 10
        self.title = deviceType
        navigationItem.hidesBackButton = true
        
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        
        mViewModel = BluetoothViewModel()
    }

    @IBAction func saveReadingLIst(_ sender: UIButton) {
        
        mViewModel?.insertVitalReadingList(deviceType: deviceType, readingList: mReadingList!, isBluetooth: true)
        let dashboardViewModel = DashboardViewModel()
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: deviceType, readingList: mReadingList!)
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}


extension ReadingsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let readingList = mReadingList else {
            return 0
        }
        return readingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "readingListCell") as! ReadingsDetailTableViewCell
        
        let readingDict = mReadingList![indexPath.row]
        cell.timeStampLabel.text = readingDict["createdTime"]
        
        switch deviceType {
        case "Glucometer":
            cell.readingLabel.text = "\(String(describing: readingDict["glucose"]!))"
        case "Blood Pressure":
            cell.readingLabel.text = "\(String(describing: readingDict["systolic"]!))/\(String(describing: readingDict["diastolic"]!)) bmp: \(String(describing: readingDict["bmp"]!))"
        case "Weight Scale":
            cell.readingLabel.text = "\(String(describing: readingDict["weight"]!)) lbs"
        case "Thermometer":
            cell.readingLabel.text = "\(String(describing: readingDict["temperature"]!)) °F"
        case "Pulse Oximeter":
            cell.readingLabel.text = "\(String(describing: readingDict["spo2"]!))% (\(String(describing: readingDict["bmp"]!)))"
        default:
            return cell
        }
        

        return cell
    }
}
