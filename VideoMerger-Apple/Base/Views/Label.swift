//
//  Label.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

class Label: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = Constants.fontMinimumScaleFactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
