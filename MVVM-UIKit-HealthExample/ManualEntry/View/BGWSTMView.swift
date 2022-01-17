//
//  BGWSTMView.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit
import fluid_slider

class BGWSTMView: UIView {
    
    @IBOutlet weak var glucoseLabel: UILabel!
    @IBOutlet weak var slider: Slider!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var vitalTypeLabel: UILabel!
    
    private var database: String?
    private var mViewModel: ManualEntryViewModel?
    var deviceType: String = ""
    
    private var initialValue: String?
    private var minimumValue: String?
    private var maximumValue: String?
    private var formatString = "%.0f"
    
    weak var closeManualEntryDelegate: CloseManualEntryDelegate!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 1. Load .xib
        let viewNib = Bundle.main.loadNibNamed("BGWSTMView", owner: self, options: nil)![0] as! UIView
        // 2. Adjust bounds
        self.bounds = viewNib.bounds
        // 3. Add as a subview
        addSubview(viewNib)
        
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initialSetup(deviceType: String) {
        self.deviceType = deviceType
        configure()
    }

    func configure() {
        
        switch (deviceType) {
        case "Glucometer":
            minimumValue = "18"
            maximumValue = "600"
            initialValue = "92"
            vitalTypeLabel.text = "mg/dl"
            slider.contentViewColor = UIColor(hexString: "#4E4DE0")
            saveButton.backgroundColor = UIColor(hexString: "#4E4DE0")
        case "Weight Scale":
            minimumValue = "3"
            maximumValue = "350"
            initialValue = "110"
            vitalTypeLabel.text = "lbs"
            slider.contentViewColor = UIColor(hexString: "#C8503C")
            saveButton.backgroundColor = UIColor(hexString: "#C8503C")
        case "Thermometer":
            minimumValue = "93.2"
            maximumValue = "109.2"
            initialValue = "97.0"
            vitalTypeLabel.text = "°F"
            formatString = "%.1f"
            slider.contentViewColor = UIColor(hexString: "#6D2A6C")
            saveButton.backgroundColor = UIColor(hexString: "#6D2A6C")
        default:
            print(deviceType)
        }

        glucoseLabel.text = initialValue
        
        saveButton.layer.cornerRadius = 10
        slider.layer.cornerRadius = 10
        
        // Configure Slider object here
        let labelTextAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.white]
        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 1
            return NSAttributedString(string: self.initialValue!, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.black])
        }
        slider.setMinimumLabelAttributedText(NSAttributedString(string: minimumValue!, attributes: labelTextAttributes))
        slider.setMaximumLabelAttributedText(NSAttributedString(string: maximumValue!, attributes: labelTextAttributes))
        slider.fraction = 0.1
        slider.shadowOffset = CGSize(width: 0, height: 10)
        slider.shadowBlur = 5
        slider.shadowColor = UIColor(white: 0, alpha: 0.1)
        slider.valueViewColor = .white

        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    @objc func sliderValueChanged(sender: Slider) {
        let fraction = sender.fraction

        var max: CGFloat = 0
        var min: CGFloat = 0
        if let maxFloat = Float(self.maximumValue!) {
            max = CGFloat(maxFloat)
        }
        if let minFloat = Float(self.minimumValue!) {
            min = CGFloat(minFloat)
        }
        let total = max - min
        let currentScale = min + (total * fraction)
        let displayValue = Float(currentScale)
        self.glucoseLabel.text = String(format: self.formatString, displayValue)
        self.slider.attributedTextForFraction  = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 1
            let string = String(format: self.formatString, displayValue)
            return NSAttributedString(string: string, attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.black])
        }
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {

        if database == DatabaseEnum.coredata.rawValue {
            mViewModel = ManualEntryViewModel(with: VitalReadingCDRepository(context: CoreDataContextProvider.sharedInstance.managedObjectContext))
        } else {
            mViewModel = ManualEntryViewModel(with: RealmRepository())
        }
        let timeStamp = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy hh:mm a"
        let dateString = formatter.string(from: timeStamp)
        let vitalReading = VitalReading(createdTimestamp: dateString, readingValue1: glucoseLabel.text!, readingValue2: "", readingValue3: "", isBluetooth: false, vitalType: self.deviceType)
        mViewModel?.insertVitalReading(vitalReading: vitalReading)
        
        var readingList = [Dictionary<String,String>]()
        switch (self.deviceType) {
        case "Glucometer":
            readingList.insert(["createdTime": dateString, "glucose": glucoseLabel.text!], at: 0)
        case "Weight Scale":
            readingList.insert(["createdTime": dateString, "weight": glucoseLabel.text!], at: 0)
        case "Thermometer":
            readingList.insert(["createdTime": dateString, "temperature": glucoseLabel.text!], at: 0)
        default:
            print(self.deviceType)
        }
        
        let dashboardViewModel = DashboardViewModel()
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: self.deviceType, readingList: readingList)
        closeManualEntryDelegate.didTapSaveButton()
    }
}
