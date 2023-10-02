//
//  String+Extensions.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation


extension String {
    
    internal var localize: String {
        return NSLocalizedString(self, comment: "")
    }
}
