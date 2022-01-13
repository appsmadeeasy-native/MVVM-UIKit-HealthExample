//
//  OxygenView.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

class OxygenView: ProgrammaticView {
    
    private let vitalNameStackView = UIStackView()
    private let oxygenLabel = UILabel()
    private let heartRateLabel = UILabel()
    private let vitalTypeStackView = UIStackView()
    private let spO2Label = UILabel()
    private let bmpLabel = UILabel()
    private let pickerViewStackView = UIStackView()
    private let oxygenPickerView = UIPickerView()
    private let heartRatePickerView = UIPickerView()
    private let saveButton = UIButton()
    
    private var database: String?
    private var mViewModel: ManualEntryViewModel?
    private let deviceType: String = "Pulse Oximeter"
    private let grayWhiteColor = "#FAFAFA"
    
    private let spO2MinValue = 70
    private let spO2MaxValue = 100
    private var spO2SetValue = 27
    private let bmpMinValue = 30
    private let bmpMaxValue = 250
    private var bmpSetValue = 35
    private var spO2Values = [String]()
    private var spO2SelectedValue = ""
    private var bmpValues = [String]()
    private var bmpSelectedValue = ""
    
    var closeManualEntryDelegate: CloseManualEntryDelegate!

    override func configure() {
        backgroundColor = UIColor(hexString: grayWhiteColor)
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")

        configureVitalNameViews()
        configureVitalTypes()
        configurePickerViews()
        configureSaveButton()
    }

    override func constrain() {
        constrainVitalNameViews()
        constrainVitalTypes()
        constrainPickerViews()
        constrainSaveButton()
    }
    
    private func configureVitalNameViews() {
        vitalNameStackView.axis = .horizontal
        vitalNameStackView.distribution = .fillEqually
        vitalNameStackView.alignment = .bottom

        oxygenLabel.text = "Oxygen"
        oxygenLabel.textAlignment = .center
        oxygenLabel.textColor = UIColor.lightGray
        heartRateLabel.text = "Heart Rate"
        heartRateLabel.textAlignment = .center
        heartRateLabel.textColor = UIColor.lightGray
        
        addConstrainedSubview(vitalNameStackView)
        vitalNameStackView.addArrangedSubviews(oxygenLabel, heartRateLabel)
    }
    
    private func constrainVitalNameViews() {
        NSLayoutConstraint.activate([
            vitalNameStackView.topAnchor.constraint(equalTo: topAnchor),
            vitalNameStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            vitalNameStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            vitalNameStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15),
        ])
    }
    
    private func configureVitalTypes() {
        vitalTypeStackView.axis = .horizontal
        vitalTypeStackView.distribution = .fillEqually
        vitalTypeStackView.alignment = .top
        
        spO2Label.text = "% SpO2"
        spO2Label.textAlignment = .center
        spO2Label.textColor = UIColor.lightGray
        spO2Label.font = UIFont.systemFont(ofSize: 15)
        bmpLabel.text = "bmp"
        bmpLabel.textAlignment = .center
        bmpLabel.textColor = UIColor.lightGray
        bmpLabel.font = UIFont.systemFont(ofSize: 15)
        
        addConstrainedSubview(vitalTypeStackView)
        vitalTypeStackView.addArrangedSubviews(spO2Label, bmpLabel)
    }
    
    private func constrainVitalTypes() {
        NSLayoutConstraint.activate([
            vitalTypeStackView.topAnchor.constraint(equalTo: vitalNameStackView.bottomAnchor),
            vitalTypeStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            vitalTypeStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            vitalTypeStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.03),
        ])
    }
    
    private func configurePickerViews() {
        for index in spO2MinValue...spO2MaxValue {
            spO2Values.append(String(index))
        }
        for index in bmpMinValue...bmpMaxValue {
            bmpValues.append(String(index))
        }
        pickerViewStackView.axis = .horizontal
        pickerViewStackView.distribution = .fillEqually
        pickerViewStackView.alignment = .center
        
        oxygenPickerView.tag = 0
        oxygenPickerView.delegate = self
        oxygenPickerView.dataSource = self
        heartRatePickerView.tag = 1
        heartRatePickerView.delegate = self
        heartRatePickerView.dataSource = self
        
        oxygenPickerView.selectRow(spO2SetValue, inComponent: 0, animated: false)
        heartRatePickerView.selectRow(bmpSetValue, inComponent: 0, animated: false)
        
        addConstrainedSubview(pickerViewStackView)
        pickerViewStackView.addArrangedSubviews(oxygenPickerView, heartRatePickerView)
    }
    
    private func constrainPickerViews() {
        NSLayoutConstraint.activate([
            pickerViewStackView.topAnchor.constraint(equalTo: vitalTypeStackView.bottomAnchor),
            pickerViewStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 60),
            pickerViewStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            pickerViewStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.30),
        ])
    }
    
    private func configureSaveButton() {
        saveButton.layer.cornerRadius = 10
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        saveButton.backgroundColor = UIColor(hexString: "#5641FF")
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        addConstrainedSubview(saveButton)
    }

    private func constrainSaveButton() {
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            saveButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.07)
            ])
    }
    
    @objc func saveButtonAction(sender: UIButton) {

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
        
        if (self.spO2SelectedValue == "") {
            self.spO2SelectedValue = self.spO2Values[self.spO2SetValue]
        }
        if (self.bmpSelectedValue == "") {
            self.bmpSelectedValue = self.bmpValues[self.bmpSetValue]
        }

        let vitalReading = VitalReading(createdTimestamp: dateString, readingValue1: self.spO2SelectedValue, readingValue2: self.bmpSelectedValue, readingValue3: "", isBluetooth: false, vitalType: deviceType)
        mViewModel?.insertVitalReading(vitalReading: vitalReading)
        let dashboardViewModel = DashboardViewModel()
        let readingList = [["createdTime": dateString, "spo2": self.spO2SelectedValue, "bmp": self.bmpSelectedValue]]
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: deviceType, readingList: readingList)
        closeManualEntryDelegate.didTapSaveButton()
    }
}

extension OxygenView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView.tag) {
        case 0:
            return self.spO2Values.count
        case 1:
            return self.bmpValues.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView.tag) {
        case 0:
            return self.spO2Values[row]
        case 1:
            return self.bmpValues[row]
        default:
            return "Data not found!"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch(pickerView.tag) {
        case 0:
            self.spO2SelectedValue = spO2Values[row]
        case 1:
            self.bmpSelectedValue = bmpValues[row]
        default:
            return
        }
    }
    
}
