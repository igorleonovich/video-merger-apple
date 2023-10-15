//
//  ResponseEntity.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation
import SwiftyJSON

public struct FiltersResponse {
    
    public let filters: [ImageFilterDTO]
}


// MARK: Decodable

extension FiltersResponse: Decodable {
    
    public static func decode(_ json: JSON) throws -> FiltersResponse {
        
        guard let filtersJson = json["filters"].array else {
            throw NetworkError.IncorrectDataReturned
        }

        var filters = [ImageFilterDTO]()
        for json in filtersJson {
            filters.append(try ImageFilterDTO.decode(json))
        }

        return FiltersResponse(
            filters: filters
        )
    }
}
