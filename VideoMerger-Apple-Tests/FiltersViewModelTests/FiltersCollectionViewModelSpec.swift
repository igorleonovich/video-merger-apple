//
//  FiltersCollectionViewModelSpec.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import Foundation
import Nimble
import Quick
import RxSwift

@testable import VideoMerger_Apple


final class FiltersCollectionViewModelSpec: QuickSpec {

    // MARK: Stub

    class StubImageSearch: FiltersGetting {
        
        func getFilters() -> Observable<FiltersResponse> {
            return Observable.create { observer -> Disposable in
                observer.onNext(dummyResponse)
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }

    class StubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String : Any]?) -> Observable<Any> {
            
            return Observable.create { observable -> Disposable in
                observable.onCompleted()

                return Disposables.create()
            }
        }
    }

    
    // MARK: Spec

    override class func spec() {
        
        var viewModel: FiltersCollectionViewModel!
        beforeEach {
            viewModel = FiltersCollectionViewModel(filtersService: StubImageSearch(), network: StubNetwork())
        }

        it("eventually sets cellModels property after the search.") {
            
            var cellModels: [FiltersCollectionViewCellModeling] = []
            viewModel.getFilters().subscribe(onNext: { models in
                cellModels = models
                }).disposed(by: DisposeBag())

            expect(cellModels).toEventuallyNot(beNil())
            expect(cellModels.count).toEventually(equal(2))
            expect(cellModels[0].imageFilter.title).toEventually(equal("title1"))
            expect(cellModels[1].imageFilter.title).toEventually(equal("title2"))
        }

        it("sets cellModels property on the main thread.") {
            
            var onMainThread = false
            viewModel.getFilters().subscribe(onNext: { models in
                onMainThread = Thread.isMainThread
                }).disposed(by: DisposeBag())
            
            expect(onMainThread).toEventually(beTrue())
        }
    }
}
