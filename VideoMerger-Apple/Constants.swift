//
//  Constants.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

struct Constants {
    
    // MARK: General
    
    static let fontMinimumScaleFactor: CGFloat = 0.5
    
    
    // MARK: Video
    
    static let maxVideoFilesCount = 100
    static let defaultVideoSize = CGSize(width: 720, height: 1280) // Default video size
    static let frameDuration: Int32 = 30
    static let outputFileType = "public.mpeg-4"
    static let outputExtension = "mp4"
}
