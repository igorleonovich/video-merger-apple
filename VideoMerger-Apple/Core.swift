//
//  Core.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

final class Core {
    
    let localFileManager: LocalFileManager!
    let videoManager: VideoManager!
    
    init() {
        localFileManager = LocalFileManager()
        videoManager = VideoManager()
        videoManager.core = self
    }
}
