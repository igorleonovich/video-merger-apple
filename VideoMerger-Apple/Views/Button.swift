//
//  Button.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

class Button: UIButton {
    
    init() {
        super.init(frame: .zero)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = Constants.fontMinimumScaleFactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var state: UIControl.State {
        get {
            switch super.state {
            case .highlighted:
                alpha = 0.8
            default:
                alpha = 1
            }
            return super.state
        }
    }
}
