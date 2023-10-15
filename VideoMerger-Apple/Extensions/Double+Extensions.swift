//
//  Double+Extensions.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 15/10/2023.
//

import CoreMedia
import Foundation

extension Double {
    
    func toCMTime() -> CMTime {
        
        return CMTime(seconds: self, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    }
}
