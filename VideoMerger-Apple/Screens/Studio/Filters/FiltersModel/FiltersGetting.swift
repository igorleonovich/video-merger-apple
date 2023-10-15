//
//  FiltersGetting.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift

public protocol FiltersGetting {
    
    func getFilters() -> Observable<FiltersResponse>
}
