//
//  FiltersCollectionViewCellModeling.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift
import UIKit

public protocol FiltersCollectionViewCellModeling {
    
    var name: String { get }
    var title: String { get }
}
