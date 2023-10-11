//
//  DummyResponse.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import UIKit
@testable import VideoMerger_Apple

let dummyResponse: ResponseEntity = {
    
    let filter0 = ImageFilterDTO(
        name: "name1",
        title: "title1")
    let filter1 = ImageFilterDTO(
        name: "name2",
        title: "title2")
    return ResponseEntity(totalCount: 2, filters: [filter0, filter1])
}()