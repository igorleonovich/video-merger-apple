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
                overlayView.alpha = 0.75
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
    
    // MARK: Updates
    
    func configure(with url: URL) {
        
        imageView.image = imagePreview(from: url, in: 0)
    }
    
    func imagePreview(from moviePath: URL, in seconds: Double) -> UIImage? {
        
        // INFO: There is no urgency to pass it on global queue for only 1 thumbnail
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 60)
        let asset = AVURLAsset(url: moviePath)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else {
            return nil
        }
        return UIImage(cgImage: imageRef)
    }
}
