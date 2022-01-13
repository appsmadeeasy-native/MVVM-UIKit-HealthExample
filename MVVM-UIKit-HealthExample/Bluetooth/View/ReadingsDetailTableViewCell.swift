//
//  ReadingsDetailTableViewCell.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/25/21.
//

import UIKit

class ReadingsDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundCardView.layer.cornerRadius = 10.0
        backgroundCardView.layer.shadowColor = UIColor.black.cgColor
        backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundCardView.layer.shadowRadius = 6.0
        backgroundCardView.layer.shadowOpacity = 0.7
    }
}
