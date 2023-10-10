//
//  Font.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import UIKit

enum Font {
    
    case small
    case medium
    case mediumBold
    case large
    case largeBlack
    
    var size: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium, .mediumBold:
            return 16
        case .large:
            return 18
        case .largeBlack:
            return 24
        }
    }
    
    var uifont: UIFont {
        switch self {
        case .mediumBold:
            return Font.appFont(size: size, weight: .bold)
        case .largeBlack:
            return Font.appFont(size: size, weight: .black)
        default:
            return Font.appFont(size: size)
        }
    }
    
    static func appFont(size: CGFloat, weight: UIFont.Weight = .thin) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
