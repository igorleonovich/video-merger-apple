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
    case large
    
    var size: CGFloat {
        switch self {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 18
        }
    }
    
    var uifont: UIFont {
        switch self {
        case .large:
            return Font.appFont(size: size, weight: .heavy)
        default:
            return Font.appFont(size: size)
        }
    }
    
    static func appFont(size: CGFloat, weight: UIFont.Weight = .thin) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
