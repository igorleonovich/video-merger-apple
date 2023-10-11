//
//  ImageFilter.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import CoreImage
import Foundation
import SwiftyJSON

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


public struct ImageFilterDTO: Codable {
    
    let name: String
    let title: String
    
    static func decode(_ e: JSON) throws -> ImageFilterDTO {

        guard let name = e["name"].string,
              let title = e["title"].string else {
            throw NetworkError.IncorrectDataReturned
        }

        return ImageFilterDTO(name: name, title: title)
    }
}

struct ImageFiltersDTO: Codable {
    
    let filters: [ImageFilterDTO]
}
