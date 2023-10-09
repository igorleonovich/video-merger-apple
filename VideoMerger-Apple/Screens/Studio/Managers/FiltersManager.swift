//
//  FiltersManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import CoreImage
import Foundation

final class FiltersManager {
    
    var filters: [ImageFilter] = [.noFilter]
    private var filtersDTO = [ImageFilterDTO]()
    
    
    func load(_ completion: @escaping () -> Void) {
        
        readJsonFile()
        setupFilters()
        completion()
    }

    private func readJsonFile()  {
        
        if let path = Bundle.main.path(forResource: "filters", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                filtersDTO = try JSONDecoder().decode([ImageFilterDTO].self, from: data)
                Log.standard("[STUDIO] Filters decoded:\n\(filtersDTO.map({ $0.title }))")
            } catch {
                // Handle error
            }
        }
    }
    
    private func setupFilters() {
        
        filtersDTO.forEach { imageFilterDTO in
            filters.append(ImageFilter.custom(imageFilterDTO))
        }
    }
    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        // TODO: Change to implicit unwrapping, add error handling
        return filter.outputImage!
    }
}
