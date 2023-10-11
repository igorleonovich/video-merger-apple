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
    
    var filters: [ImageFilter] = [.noFilter]
    var filtersDTO = [ImageFilterDTO]()
    
    var selectedFilterIndex = 0
    
    lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        return config
    }()
    
    var getFiltersTask: URLSessionDataTask?
    
    
    // MARK: Loading
    
    
    // MARK: Applying filters
    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        // TODO: Change to implicit unwrapping, add error handling
        return filter.outputImage!
    }
    
    func applyThumbnail(with url: URL, imageFilter: ImageFilter, filtersManager: FiltersManager, localFileManager: LocalFileManager,
                        completion: ((UIImage?) -> Void)? = nil) {
        
        let thumbnailFilename = "\(url.fileName).\(url.pathExtension).thumbnail.\(imageFilter.title)"
        let thumbnailUrl = localFileManager.fileURL(fileName: thumbnailFilename, fileFormat: "png")
        
        if localFileManager.isFileExists(fileName: thumbnailFilename, fileFormat: "png"),
           let data = try? Data(contentsOf: thumbnailUrl), let image = UIImage(data: data) {
            
            applyImage(image: image)
            func applyImage(image: UIImage) {
                
                completion?(image)
            }
        } else {
            let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            if let cgImage = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
                
                let thumbnailCIImage = CIImage(cgImage: cgImage)
                
                if let filter = imageFilter.filter {
                    let filteredCIImage = filtersManager.apply(filter, for: thumbnailCIImage)
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


// MARK: Helpers

final class SessionDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, nil)
    }
}
