//
//  PressureView.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

class PressureView: ProgrammaticView {

    private let stackViewForVitalDisplay = UIStackView()
    private let stackViewForTextFields = UIStackView()
    private let systolicTextField = UITextField()
    private let diastolicTextField = UITextField()
    private let heartRateTextField = UITextField()
    private let deviderLabel = UILabel()
    
    private let stackViewForLables = UIStackView()
    private let systolicLabel = UILabel()
    private let diastolicLabel = UILabel()
    private let heartRateLabel = UILabel()
    
    private let saveButton = UIButton()
    
    private let stackViewForViews = UIStackView()
    private let vitalDisplayView = UIView()
    private let keypadView = UIView()
    
    private var database: String?
    private var mViewModel: ManualEntryViewModel?
    private let deviceType: String = "Blood Pressure"
    private let grayWhiteColor = "#FAFAFA"
    
    weak var closeManualEntryDelegate: CloseManualEntryDelegate!
  
    override func configure() {
        let defaults = UserDefaults.standard
        database = defaults.string(forKey: "database")

        configureBackgroundViews()
        configureVitalEntries()
        configureSaveButton()
        
        systolicTextField.becomeFirstResponder()
    }

    override func constrain() {
        constrainBackgroundViews()
        constrainVitalEntries()
        constrainSaveButton()
    }
    
    private func configureBackgroundViews() {
        stackViewForViews.axis = .vertical
        stackViewForViews.distribution = .fill

        vitalDisplayView.backgroundColor = UIColor(hexString: "#85A4D5")
        keypadView.backgroundColor = UIColor(hexString: grayWhiteColor)
        
        addConstrainedSubviews(stackViewForViews)
        stackViewForViews.addArrangedSubviews(vitalDisplayView, keypadView)
    }
    
    private func constrainBackgroundViews() {
        NSLayoutConstraint.activate([
            stackViewForViews.topAnchor.constraint(equalTo: topAnchor),
            stackViewForViews.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackViewForViews.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackViewForViews.bottomAnchor.constraint(equalTo: bottomAnchor),
            vitalDisplayView.heightAnchor.constraint(equalTo: stackViewForViews.heightAnchor, multiplier: 0.28),
        ])
    }

    private func configureVitalEntries() {
        stackViewForVitalDisplay.axis = .vertical
        stackViewForVitalDisplay.distribution = .fill
        vitalDisplayView.addConstrainedSubviews(stackViewForVitalDisplay)
        
        stackViewForTextFields.axis = .horizontal
        stackViewForTextFields.spacing = 30
        stackViewForTextFields.distribution = .fillEqually
        stackViewForTextFields.alignment = .bottom
        configureTextField(textField: systolicTextField)
        systolicTextField.tag = 0
        configureTextField(textField: diastolicTextField)
        diastolicTextField.tag = 1
        configureTextField(textField: heartRateTextField)
        heartRateTextField.tag = 2
        stackViewForTextFields.addArrangedSubviews(systolicTextField, diastolicTextField, heartRateTextField)
        
        deviderLabel.text = "/"
        deviderLabel.font = UIFont.systemFont(ofSize: 40)
        deviderLabel.textColor = UIColor(hexString: grayWhiteColor)
        addConstrainedSubview(deviderLabel)
        
        stackViewForLables.axis = .horizontal
        stackViewForLables.spacing = 15
        stackViewForLables.distribution = .fillEqually
        configureVitalNameLabels(vitalLabel: systolicLabel)
        systolicLabel.text = "Systolic"
        configureVitalNameLabels(vitalLabel: diastolicLabel)
        diastolicLabel.text = "Diastolic"
        configureVitalNameLabels(vitalLabel: heartRateLabel)
        heartRateLabel.text = "Heart Rate"
        stackViewForLables.addArrangedSubviews(systolicLabel, diastolicLabel, heartRateLabel)
        
        stackViewForVitalDisplay.addArrangedSubviews(stackViewForTextFields, stackViewForLables)
    }
    
    private func configureTextField(textField: UITextField) {
        // Set cursor color
        textField.tintColor = UIColor(hexString: grayWhiteColor)
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor(hexString: grayWhiteColor),
                          .font: UIFont.systemFont(ofSize: 40)]
        textField.attributedPlaceholder = NSAttributedString(string: "...", attributes: attributes)
        
        textField.textColor = UIColor(hexString: grayWhiteColor)
        textField.textAlignment = .right
        textField.font = UIFont.systemFont(ofSize: 50)
        textField.delegate = self
        textField.keyboardType = .numberPad
        textField.addBottomBorder(height: 2.0, color: UIColor(hexString: grayWhiteColor))
    }
    
    private func configureVitalNameLabels(vitalLabel: UILabel) {
        vitalLabel.textColor = UIColor(hexString: grayWhiteColor)
        vitalLabel.font = UIFont.systemFont(ofSize: 12)
        vitalLabel.textAlignment = .center
    }
    
    private func constrainVitalEntries() {
        NSLayoutConstraint.activate([
            stackViewForVitalDisplay.topAnchor.constraint(equalTo: vitalDisplayView.topAnchor),
            stackViewForVitalDisplay.leadingAnchor.constraint(equalTo: vitalDisplayView.leadingAnchor, constant: 20),
            stackViewForVitalDisplay.trailingAnchor.constraint(equalTo: vitalDisplayView.trailingAnchor, constant: -20),
            stackViewForVitalDisplay.bottomAnchor.constraint(equalTo: vitalDisplayView.bottomAnchor),
            stackViewForTextFields.heightAnchor.constraint(equalTo: vitalDisplayView.heightAnchor, multiplier: 0.80),
            systolicTextField.heightAnchor.constraint(equalTo: vitalDisplayView.heightAnchor, multiplier: 0.25),
            diastolicTextField.heightAnchor.constraint(equalTo: vitalDisplayView.heightAnchor, multiplier: 0.25),
            heartRateTextField.heightAnchor.constraint(equalTo: vitalDisplayView.heightAnchor, multiplier: 0.25),
            deviderLabel.leadingAnchor.constraint(equalTo: systolicTextField.trailingAnchor, constant: 10),
            deviderLabel.trailingAnchor.constraint(equalTo: diastolicTextField.leadingAnchor),
            deviderLabel.topAnchor.constraint(equalTo: systolicTextField.topAnchor, constant: 5),
        ])
    }
    
    private func configureSaveButton() {
        saveButton.layer.cornerRadius = 10
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        saveButton.backgroundColor = UIColor(hexString: "D3D3D3")      //active color UIColor(hexString: "#5641FF")
        saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
        saveButton.isEnabled = false
        keypadView.addConstrainedSubview(saveButton)
    }
    
    private func constrainSaveButton() {
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: keypadView.topAnchor, constant: 50),
            saveButton.leadingAnchor.constraint(equalTo: keypadView.leadingAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: keypadView.trailingAnchor, constant: -50),
            saveButton.heightAnchor.constraint(equalTo: keypadView.heightAnchor, multiplier: 0.10)
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
        let vitalReading = VitalReading(createdTimestamp: dateString, readingValue1: systolicTextField.text!, readingValue2: diastolicTextField.text!, readingValue3: heartRateTextField.text!, isBluetooth: false, vitalType: deviceType)
        mViewModel?.insertVitalReading(vitalReading: vitalReading)
        let dashboardViewModel = DashboardViewModel()
        let readingList = [["createdTime": dateString, "systolic": systolicTextField.text!, "diastolic": diastolicTextField.text!, "bmp": heartRateTextField.text!]]
        dashboardViewModel.updateLastVitalReadingToDevice(deviceType: deviceType, readingList: readingList)
        closeManualEntryDelegate.didTapSaveButton()
    }
}

extension PressureView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        // Check for invalid input characters (Only allow numeric characters)
        if !CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) {
            return false
        }
        
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // Enable/disable SaveButton
        switch(textField.tag) {
        case 0:
            if (diastolicTextField.hasText &&
                heartRateTextField.hasText &&
                updateText.count > 0) {
                saveButtonColorAndState(isColorAndState: true)
            } else {
                saveButtonColorAndState(isColorAndState: false)
            }
        case 1:
            if (systolicTextField.hasText &&
                heartRateTextField.hasText &&
                updateText.count > 0) {
                saveButtonColorAndState(isColorAndState: true)
            } else {
                saveButtonColorAndState(isColorAndState: false)
            }
        case 2:
            if (systolicTextField.hasText &&
                diastolicTextField.hasText &&
                updateText.count > 0) {
                saveButtonColorAndState(isColorAndState: true)
            } else {
                saveButtonColorAndState(isColorAndState: false)
            }
        default:
            print(textField.text!)
        }

        return updateText.count < 4
    }
    
    func saveButtonColorAndState(isColorAndState: Bool) {
        if isColorAndState {
            self.saveButton.backgroundColor = UIColor(hexString: "#5641FF")
            self.saveButton.isEnabled = true
        } else {
            self.saveButton.backgroundColor = UIColor(hexString: "D3D3D3")
            self.saveButton.isEnabled = false
        }
    }
}
