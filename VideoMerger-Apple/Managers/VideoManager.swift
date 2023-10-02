//
//  VideoManager.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

final class VideoManager {
    
    weak var core: Core?
    
    lazy var outputURL: URL? = {
        return core?.localFileManager.fileURL(fileName: "output", fileFormat: "mp4")
    }()
}
