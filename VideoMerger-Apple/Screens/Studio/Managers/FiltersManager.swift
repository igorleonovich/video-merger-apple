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
    private var filtersDTO = [ImageFilterDTO]()
    
    var selectedFilterIndex = 0
    
    lazy var sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        return config
    }()
    
    var getFiltersTask: URLSessionDataTask?
    
    
    // MARK: Loading
    
    func load(_ completion: @escaping () -> Void) {
        
        getFilters { [weak self] error in
            if let error = error {
                Log.error(error.localizedDescription)
            } else {
                self?.filtersDTO.forEach { imageFilterDTO in
                    self?.filters.append(ImageFilter.custom(imageFilterDTO))
                }
                completion()
            }
        }
    }
    
    func getFilters(_ completion: @escaping (Swift.Error?) -> Void) {
        
        getFiltersTask?.cancel()
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: sessionConfiguration, delegate: sessionDelegate, delegateQueue: OperationQueue.main)
        
        let path = "/filters.json"
        guard let url = URL(string: "\(Constants.baseUrl)\(path)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        getFiltersTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            defer {
                self.getFiltersTask = nil
            }
            if let error = error {
                completion(error)
            } else if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    
                    do {
                        filtersDTO = try JSONDecoder().decode([ImageFilterDTO].self, from: data)
                        completion(nil)
                    } catch {
                        completion(error)
                    }
                        
                    Log.standard("[FILTERS] \(request.httpMethod ?? "") \(path) \(response.statusCode)")
                } else {
                    
                    Log.error("[FILTERS] \(request.httpMethod ?? "") \(path) \(response.statusCode)")
                }
            }
        }
        getFiltersTask?.resume()
    }
    
    
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
