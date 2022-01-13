//
//  UIStackView+Helpers.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { view in addArrangedSubview(view) }
    }
}
