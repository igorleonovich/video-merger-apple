//
//  Log.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Foundation

struct Log {
    
    static func standard(_ string: String) {
        print("\n\(string)")
    }
    
    static func error(_ string: String) {
        print("\n⭕️\n\(string)")
    }
}
