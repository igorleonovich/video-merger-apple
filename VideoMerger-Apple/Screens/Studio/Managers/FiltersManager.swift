//
//  FiltersManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import Foundation

final class FiltersManager {
    
    var filters = [ImageFilter]()
    
    init() {
        setupFilters()
    }
    
    private func setupFilters() {
        filters = ImageFilter.allCases
        filters.append(contentsOf: [ImageFilter.remote, ImageFilter.remote, ImageFilter.remote, ImageFilter.remote])
    }
}
