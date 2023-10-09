//
//  ClipCell.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import AVFoundation
import UIKit

final class ClipCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var overlayView: UIView!
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                overlayView.alpha = 0
            } else {
                overlayView.alpha = 0.5
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup
    
    private func setupUI() {
        
        setupImageView()
        setupOverlay()
    }
    
    private func setupImageView() {
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOverlay() {
        
        overlayView = UIView()
        addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        overlayView.backgroundColor = .black
        overlayView.alpha = 0
    }
    
    
    // MARK: Configuration
    
    func configure(with url: URL, imageFilter: ImageFilter, filtersManager: FiltersManager, localFileManager: LocalFileManager) {
        
        DispatchQueue.global().async {
            
            let thumbnailFilename = "\(url.fileName).\(url.pathExtension).thumbnail.\(imageFilter.title)"
            let thumbnailUrl = localFileManager.fileURL(fileName: thumbnailFilename, fileFormat: "png")
            
            if localFileManager.isFileExists(fileName: thumbnailFilename, fileFormat: "png"),
               let data = try? Data(contentsOf: thumbnailUrl), let image = UIImage(data: data) {
                
                applyImage(image: image)
                func applyImage(image: UIImage) {
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = image
                    }
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
                        
                        DispatchQueue.main.async { [weak self] in
                            
                            self?.imageView.image = image
                            if let data = self?.imageView.image?.pngData() {
                                DispatchQueue.global().async {
                                    try? data.write(to: thumbnailUrl)
                                }
                            }
                        }
                    }
                }
            }
            
//            guard let thumbnailCIImage = thumbnailCIImage else { return }
//
//            if let filter = imageFilter.filter {
//                let filteredImage = filtersManager.apply(filter, for: thumbnailCIImage)
//                self.imageView.image = nil
//                self.imageView.image = UIImage(ciImage: filteredImage)
//            } else {
//                self.imageView.image = UIImage(ciImage: thumbnailCIImage)
//            }
        }
    }
}
