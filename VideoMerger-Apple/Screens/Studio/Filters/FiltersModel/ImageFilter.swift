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
    case custom(ImageFilterDTO)
    
    var filter: CIFilter? {
        switch self {
        case .noFilter:
            return nil
        case .custom(let imageFilterDTO):
            return CIFilter(name: imageFilterDTO.name)
        }
    }
    
    var title: String {
        switch self {
        case .noFilter:
            return "Original"
        case .custom(let imageFilterDTO):
            return imageFilterDTO.title
        }
    }
}


struct ImageFilterDTO: Codable {
    
    let name: String
    let title: String
}
