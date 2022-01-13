//
//  BluetoothViewController.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 4/1/21.
//

import UIKit
import Gifu
import TinyConstraints

class BluetoothViewController: UIViewController, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var readingButton: UIButton!
    @IBOutlet weak var loadingDataLabel: UILabel!
    
    private var centerManagerSvc: CentralManagerSvc?
    private var mDevice: Device?
    private var mReadingList: [Dictionary<String,String>]?
    private var mViewModel: BluetoothViewModel?
    private var database: String?
    
    private var vitalReadingList: [VitalReading]?
    private var dataSource: UITableViewDiffableDataSource<Section, VitalReading>!
        
    enum Section {
        case first
    }
    
    lazy var loadingGif: GIFImageView = {
        let view = GIFImageView()
        view.contentMode = .scaleAspectFit
        view.animate(withGIFNamed: "preview")
        return view
    }()
    
    lazy var readingList: ([Dictionary<String,String>]) -> Void = { [weak self] dictArray in
        self?.mReadingList = dictArray
        self?.performSegue(withIdentifier: "ReadingsDetail", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let device = mDevice else {
            return
        }
        mReadingList = [Dictionary<String,String>]()
        readingButton.layer.cornerRadius = 10
        navigationController?.navigationBar.topItem?.title = device.deviceType
        loadingGif.isHidden = true
        loadingDataLabel.isHidden = true
        
        view.addSubview(loadingGif)
        loadingGif.leftToSuperview()
        loadingGif.rightToSuperview()
        loadingGif.topToBottom(of: loadingDataLabel)
        loadingGif.height(130)
        
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
        
        tableView.tableFooterView = UIView()
        tableView.register(BluetoothTableViewCell.self, forCellReuseIdentifier: "cell")
        
        dataSource = createDataSource()
        
        mViewModel = BluetoothViewModel()
 
        mViewModel?.getVitalReadingsByType(vitalType: device.deviceType) { [weak self] vitalReadings in
            self?.vitalReadingList = vitalReadings
            self?.updateDataSource()
        }
    }
    
    func createDataSource() -> UITableViewDiffableDataSource<Section, VitalReading> {

        UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, model -> BluetoothTableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BluetoothTableViewCell
            if indexPath.row % 2 == 0 {
                cell.backgroundColor = UIColor.systemGray6
            } else {
                cell.backgroundColor = UIColor.white
            }
            cell.timeStampLabel.text = model.createdTimestamp
            switch model.vitalType {
            case "Glucometer":
                cell.readingLabel.text = model.readingValue1
            case "Blood Pressure":
                cell.readingLabel.text = model.readingValue1 + "/" + model.readingValue2
            case "Weight Scale":
                cell.readingLabel.text = model.readingValue1 + " lbs"
            case "Thermometer":
                cell.readingLabel.text = model.readingValue1 + " °F"
            case "Pulse Oximeter":
                cell.readingLabel.text = model.readingValue1
            default:
                cell.readingLabel.text = model.readingValue1
            }
            
            return cell
        })
    }
    
    func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, VitalReading>()
        snapshot.appendSections([.first])
        guard let vitalReadingList = vitalReadingList else {
            return
        }
        snapshot.appendItems(vitalReadingList)
        dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

    
    // MARK: - Helper Methods
    
    public func setDevice(device: Device) {
        mDevice = device
    }
    


    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if (segue.identifier == "ReadingsDetail") {
             let destView = segue.destination as! ReadingsDetailViewController
             guard let device = mDevice else {
                 return
             }
             destView.deviceType = device.deviceType
             destView.mReadingList = mReadingList
         }
     }
    
    // MARK: - Action methods
    
    @IBAction func startStopReadingAction(_ sender: UIButton) {
        if (readingButton.titleLabel?.text == "Start Reading") {
            guard let device = mDevice else {
                return
            }
            centerManagerSvc = CentralManagerSvc(device: device, readingListClosure: readingList)
            self.centerManagerSvc?.startScan()
            readingButton.setTitle(NSLocalizedString("Stop Reading", comment: ""), for: .normal)
            loadingGif.isHidden = false
            loadingDataLabel.isHidden = false
        } else {
            loadingGif.isHidden = true
            loadingDataLabel.isHidden = true
            self.centerManagerSvc?.stopScan()
            readingButton.setTitle(NSLocalizedString("Start Reading", comment: ""), for: .normal)
        }
    }
    
    @IBAction func exitBluetoothReading(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }

}
