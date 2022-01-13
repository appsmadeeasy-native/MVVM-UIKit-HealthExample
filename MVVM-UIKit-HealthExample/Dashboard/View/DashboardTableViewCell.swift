//
//  DashboardTableViewCell.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/17/21.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var manualButton: UIButton!
    @IBOutlet weak var deviceIconIV: UIImageView!
    @IBOutlet weak var lastReadingValue: UILabel!
    @IBOutlet weak var lastReadingTimeStamp: UILabel!
    @IBOutlet weak var readingScale: UILabel!
    @IBOutlet weak var readingType: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deviceIconIV.layer.cornerRadius = 0.5 * deviceIconIV.bounds.size.width
        deviceIconIV.clipsToBounds = true
        manualButton.layer.cornerRadius = 0.5 * manualButton.bounds.size.width
        manualButton.clipsToBounds = true
        
        backgroundCardView.layer.cornerRadius = 10.0
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowRadius = 6.0
        backgroundCardView.layer.shadowOpacity = 0.7
    }
}
