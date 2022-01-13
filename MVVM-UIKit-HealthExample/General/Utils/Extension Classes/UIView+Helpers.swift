//
//  UIView+Helpers.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

extension UIView {
    func addConstrainedSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
    }
    
    func addConstrainedSubviews(_ views: UIView...) {
        views.forEach { view in addConstrainedSubview(view) }
    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach { view in addSubview(view) }
    }
    
    func setBackgroundAlpha(_ alpha: CGFloat) {
        backgroundColor = backgroundColor?.withAlphaComponent(alpha)
    }
    
    public class func fromNib<T: UIView>() -> T {
            let name = String(describing: Self.self);
            guard let nib = Bundle(for: Self.self).loadNibNamed(
                    name, owner: nil, options: nil)
            else {
                fatalError("Missing nib-file named: \(name)")
            }
            return nib.first as! T
        }
}
