//
//  Networking.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift
import UIKit

public protocol Networking {
    
    func requestJSON(url: String, parameters: [String: Any]?) -> Observable<Any>
}
