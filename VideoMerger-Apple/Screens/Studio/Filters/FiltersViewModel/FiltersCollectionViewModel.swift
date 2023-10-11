//
//  FiltersCollectionViewModel.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift
import RxCocoa

public final class FiltersCollectionViewModel: FiltersCollectionViewModeling {

    public var filtersDTO: [ImageFilterDTO]?
    public let network: Networking
    private let filtersService: FiltersGetting

    public init(filtersService: FiltersGetting, network: Networking) {
        self.filtersService = filtersService
        self.network = network
    }

    public func getFilters() -> Observable<[FiltersCollectionViewCellModeling]> {
        
        return filtersService.getFilters().map { response in
            self.filtersDTO = response.filters
            return response.filters.map { filterDTO in
                FiltersCollectionViewCellModel(filterDTO: filterDTO, network: self.network)
            }
        }
    }
}
