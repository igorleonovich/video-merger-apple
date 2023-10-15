//
//  DummyResponse.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import Foundation

@testable import VideoMerger_Apple


let dummyResponse: FiltersResponse = {
    
    let filter0 = ImageFilterDTO(
        name: "name1",
        title: "title1")
    let filter1 = ImageFilterDTO(
        name: "name2",
        title: "title2")
    return FiltersResponse(filters: [filter0, filter1])
}()
