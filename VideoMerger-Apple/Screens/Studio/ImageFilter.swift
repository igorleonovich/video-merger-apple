//
//  ImageFilter.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import CoreImage
import Foundation

enum ImageFilter: String {
    
    case noFilter
    case inversion
    case remote
    
    var filter: CIFilter {
        switch self {
        case .noFilter:
            // TODO: Fix "No Filter"
            return CIFilter()
        case .inversion:
            return CIFilter(name: "CIColorInvert")!
        case .remote:
            // TODO: Make "Remote"
            return CIFilter()
        }
    }
}
