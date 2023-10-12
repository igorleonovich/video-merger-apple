//
//  FiltersCollectionViewCellModel.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

public final class FiltersCollectionViewCellModel: FiltersCollectionViewCellModeling {

    public let imageFilter: ImageFilter

    private let network: Networking
    
    internal init(filterDTO: ImageFilterDTO? = nil, network: Networking) {
        if let filterDTO {
            imageFilter = .custom(filterDTO)
        } else {
            imageFilter = .noFilter
        }
        
        self.network = network
    }
}
