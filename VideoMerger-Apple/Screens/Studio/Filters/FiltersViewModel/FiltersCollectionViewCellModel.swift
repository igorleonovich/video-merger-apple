//
//  FiltersCollectionViewCellModel.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

public final class FiltersCollectionViewCellModel: FiltersCollectionViewCellModeling {

    public let name: String
    public let title: String

    private let network: Networking
    
    internal init(filterDTO: ImageFilterDTO, network: Networking) {
        name = filterDTO.name
        title = filterDTO.title
        
        self.network = network
    }
}
