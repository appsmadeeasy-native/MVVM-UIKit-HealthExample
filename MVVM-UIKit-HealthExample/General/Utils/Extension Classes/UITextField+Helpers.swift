//
//  UITextField+Helpers.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 1/2/22.
//

import UIKit

extension UITextField {
    internal func addBottomBorder(height: CGFloat = 1.0, color: UIColor = .black) {
        let borderView = UIView()
        borderView.backgroundColor = color
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderView)
        NSLayoutConstraint.activate(
            [
                borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
                borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
                borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
                borderView.heightAnchor.constraint(equalToConstant: height)
            ]
        )
    }
}
