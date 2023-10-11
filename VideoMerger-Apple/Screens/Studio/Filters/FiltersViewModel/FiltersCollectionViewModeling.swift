//
//  FiltersCollectionViewModeling.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxCocoa
import RxSwift

public protocol FiltersCollectionViewModeling {
    
    var filtersDTO: [ImageFilterDTO]? { get }
    var network: Networking { get }

    func getFilters() -> Observable<[FiltersCollectionViewCellModeling]>
}
