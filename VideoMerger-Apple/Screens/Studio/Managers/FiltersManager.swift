//
//  FiltersManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import AVFoundation
import CoreImage
import UIKit

final class FiltersManager {
    
    private weak var localFileManager: LocalFileManager!
    private weak var clipsManager: ClipsManager!
    
    var filters: [ImageFilter] = [.noFilter]
    var selectedFilterIndex = 0
    
    
    // MARK: Life Cycle
    
    init(localFileManager: LocalFileManager, clipsManager: ClipsManager) {
        self.localFileManager = localFileManager
        self.clipsManager = clipsManager
    }
    
    
    // MARK: Applying filters
    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        // TODO: Change to implicit unwrapping, add error handling
        return filter.outputImage!
    }
    
    // MARK: Actions
    
    /* INFO: This solution works prefectly for reasonable count of filters only. In case of huge amount of filters
    it will generate thumbnails for all of them despite of not being visible on collection view */
    
    func generateThumbnailsForCurrentVideoAndAllFilters(_ completion: (() -> Void)? = nil) {
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            guard let self = self else { return }
            let group = DispatchGroup()
            
            filters.forEach { imageFilter in
                group.enter()
                self.generateThumbnail(with: self.clipsManager.inputVideoURLs[self.clipsManager.selectedClipIndex],
                                       imageFilter: imageFilter) { _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion?()
            }
        }
    }
    
    func generateThumbnailsForCurrentFilterAndAllVideos(_ completion: (() -> Void)? = nil) {
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            guard let self = self else { return }
            let group = DispatchGroup()
            
            clipsManager.inputVideoURLs.forEach { videoURL in
                group.enter()
                self.generateThumbnail(with: videoURL, imageFilter: self.filters[self.selectedFilterIndex]) { _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion?()
            }
        }
    }
    
    func generateThumbnail(with videoURL: URL, imageFilter: ImageFilter, completion: ((UIImage?) -> Void)? = nil) {
        
        let thumbnailUrl = localFileManager.thumbnailURL(for: videoURL, imageFilter: imageFilter)
        
        if localFileManager.isFileExists(fileURL: thumbnailUrl),
           let data = try? Data(contentsOf: thumbnailUrl), let image = UIImage(data: data) {

            applyImage(image: image)
            func applyImage(image: UIImage) {

                completion?(image)
            }
        } else {
            let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
            let asset = AVURLAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            if let cgImage = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
                
                let thumbnailCIImage = CIImage(cgImage: cgImage)
                
                if let filter = imageFilter.filter {
                    let filteredCIImage = apply(filter, for: thumbnailCIImage)
                    let filteredUIImage = UIImage(ciImage: filteredCIImage)
                    applyAndSaveImage(image: filteredUIImage)
                } else {
                    applyAndSaveImage(image: UIImage(ciImage: thumbnailCIImage))
                }
                
                func applyAndSaveImage(image: UIImage) {
                    
                    completion?(image)
                    
                    if let data = image.pngData() {
                        DispatchQueue.global().async {
                            try? data.write(to: thumbnailUrl)
                        }
                    }
                }
            } else {
                completion?(nil)
            }
        }
    }
}
