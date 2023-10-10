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
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
    
        filtersManager.applyThumbnail(with: url, imageFilter: imageFilter,
                                      filtersManager: filtersManager, localFileManager: localFileManager) { [weak self] image in

            DispatchQueue.main.async {
                
                self?.imageView?.image = image
            }
        }
    }
}
