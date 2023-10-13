//
//  FiltersCollectionViewCellModelSpec.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import Foundation
import Nimble
import Quick
import RxSwift

@testable import VideoMerger_Apple


final class FiltersCollectionViewCellModelSpec: QuickSpec {
    
    // MARK: Stubs
    
    class StubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String : Any]?) -> Observable<Any> {
            
            return Observable.create { observable -> Disposable in
                observable.onCompleted()
                return Disposables.create()
            }
        }
    }

    class ErrorStubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String : Any]?) -> Observable<Any> {
            
            return Observable.create { observable -> Disposable in
                observable.onCompleted()
                return Disposables.create()
            }
        }
    }

    
    // MARK: Spec
    
    override class func spec() {
        
        var viewModel: FiltersCollectionViewCellModel!
        
        beforeEach {
            viewModel = FiltersCollectionViewCellModel(
                filterDTO: dummyResponse.filters[1],
                network: StubNetwork())
        }

        describe("Constant values") {
            
            it("sets title.") {
                expect(viewModel.imageFilter.title).toEventually(equal("title2"))
            }
        }
    }
}
