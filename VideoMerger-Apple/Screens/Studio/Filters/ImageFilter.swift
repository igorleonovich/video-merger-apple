//
//  ImageFilter.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import CoreImage
import Foundation

enum ImageFilter {
    
    case noFilter
    case inversion
    case custom([CIFilter], String)
    
    var filter: CIFilter? {
        switch self {
        case .noFilter:
            // TODO: Fix "No Filter"
            return nil
        case .inversion:
            return CIFilter(name: "CIColorInvert")!
        case .custom:
            // TODO: Make Custom
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .noFilter:
            return "Original"
        case .inversion:
            return "Inversion"
        case .custom(_, let title):
            return title
        }
    }
}
