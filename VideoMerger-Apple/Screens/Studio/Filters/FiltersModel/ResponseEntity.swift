//
//  ResponseEntity.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import SwiftyJSON

public struct ResponseEntity {
    
    public let filters: [ImageFilterDTO]
}


// MARK: Decodable

extension ResponseEntity: Decodable {
    
    public static func decode(_ e: JSON) throws -> ResponseEntity {
        
        guard let filtersJson = e["filters"].array else {
            throw NetworkError.IncorrectDataReturned
        }

        var filters = [ImageFilterDTO]()
        for json in filtersJson {
            filters.append(try ImageFilterDTO.decode(json))
        }

        return ResponseEntity(
            filters: filters
        )
    }
}
