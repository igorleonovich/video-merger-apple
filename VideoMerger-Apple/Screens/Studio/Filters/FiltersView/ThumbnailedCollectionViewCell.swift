//
//  ThumbnailedCollectionViewCell.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 13/10/2023.
//

import UIKit

// INFO: Currently placed in Filters module due to MVVM implementation only for it. Also used in: ClipCell

class ThumbnailedCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    // MARK: Configuration
    
    func configure(with currentVideoUrl: URL, imageFilter: ImageFilter, localFileManager: LocalFileManager) {
        
        if let data = try? Data(contentsOf: localFileManager.thumbnailURL(for: currentVideoUrl, imageFilter: imageFilter)),
            let image = UIImage(data: data) {
            
//            Log.standard("[THUMBNAIL] Loaded thumbnail for filter '\(imageFilter.title)'")
            imageView?.image = image
            
        } else {
            Log.error("[THUMBNAIL] Can't load thumbnail for filter '\(imageFilter.title)'")
        }
    }
}
