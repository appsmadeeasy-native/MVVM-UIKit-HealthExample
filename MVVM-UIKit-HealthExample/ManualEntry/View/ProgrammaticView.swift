//
//  ProgrammaticView.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 12/25/21.
//

import UIKit

protocol CloseManualEntryDelegate: AnyObject {
    func didTapSaveButton()
}

class ProgrammaticView: UIView {

    @available(*, unavailable, message: "Don't use init(coder:), override init(frame:) instead")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        constrain()
    }

    func configure() {}
    func constrain() {}
}
