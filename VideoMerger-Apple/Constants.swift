//
//  Constants.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

struct Constants {
    
    // MARK: UI
    
    static let fontMinimumScaleFactor: CGFloat = 0.5
    static let defaultAnimationDuration: Double = 1
    
    static let backgroundColor: UIColor = .black
    static let foregroundColor: UIColor = .white
    static let tintColor: UIColor = .green
    
    // MARK: Video
    
    static let maxVideoFilesCount = 100
    static let defaultVideoSize = CGSize(width: 720, height: 1280)
    static let frameDuration: Int32 = 30
    static let outputFileType = "public.mpeg-4"
    static let outputExtension = "mp4"
    
    // MARK: Network
    
    static let baseUrl = "https://www.igorleonovich.com"
}
