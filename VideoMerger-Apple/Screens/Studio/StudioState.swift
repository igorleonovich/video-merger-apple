//
//  StudioState.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 03/10/2023.
//

import Foundation

enum StudioState: String, CaseIterable {
    
    case loading
    case ready
    case filtering
    case merging
    case exported
}
