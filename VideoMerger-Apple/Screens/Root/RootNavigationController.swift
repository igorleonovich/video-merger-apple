//
//  RootNavigationController.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import UIKit

final class RootNavigationController: UINavigationController {
    
    init(localFileManager: LocalFileManager) {
        let pickerViewController = PickerViewController(localFileManager: localFileManager)
        super.init(rootViewController: pickerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
