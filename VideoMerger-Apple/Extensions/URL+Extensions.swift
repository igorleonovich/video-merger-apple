//
//  URL+Extensions.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

extension URL {
    
    var fileName: String {
        return deletingPathExtension().lastPathComponent
    }
}
