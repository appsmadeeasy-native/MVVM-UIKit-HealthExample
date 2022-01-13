//
//  BluetoothTableViewCell.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 11/29/21.
//

import UIKit

class BluetoothTableViewCell: UITableViewCell {
    
    var timeStampLabel = UILabel()
    var readingLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(timeStampLabel)
        addSubview(readingLabel)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell() {
        timeStampLabel.numberOfLines = 0
        timeStampLabel.adjustsFontSizeToFitWidth = true
        readingLabel.numberOfLines = 0
        readingLabel.adjustsFontSizeToFitWidth = true
        setTimeStampLabelConstraints()
        setReadingLabelConstraints()
    }
    
    func setTimeStampLabelConstraints() {
        timeStampLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        timeStampLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func setReadingLabelConstraints() {
        readingLabel.translatesAutoresizingMaskIntoConstraints = false
        readingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        readingLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
