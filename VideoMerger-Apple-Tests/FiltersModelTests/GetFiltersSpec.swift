//
//  GetFiltersSpec.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import Nimble
import Quick
import RxSwift
import UIKit
@testable import VideoMerger_Apple

final class GetFiltersSpec: QuickSpec {

    private static let disposeBag = DisposeBag()
    
    // MARK: -  Stub

    class SuccessfulStubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String: Any]?) -> Observable<Any> {
            
            let json: [String: Any] = [
                "totalCount": 2,
                "filters": filtersJSON["filters"] ?? [String: Any]()
            ]
            
            return Observable.create { observer -> Disposable in
                observer.onNext(json)
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }

    class FailureStubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String: Any]?) -> Observable<Any> {
            
            let json = [String: AnyObject]()
            return Observable.create { observer -> Disposable in
                observer.onNext(json)
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }

    class ErrorStubNetwork: Networking {
        
        func requestJSON(url: String, parameters: [String: Any]?) -> Observable<Any> {
            
            return Observable.create { observer -> Disposable in
                observer.onError(NetworkError.NotConnectedToInternet)
                observer.onCompleted()
                return Disposables.create()
            }
        }
    }

    
    // MARK: - Spec

    override class func spec() {
        
        it("returns filters if the network works correctly.") {
            
            var response: ResponseEntity? = nil
            let filtersService = FiltersService(network: SuccessfulStubNetwork())

            filtersService.getFilters()
                .subscribe(onNext: {
                    response = $0
                }).disposed(by: disposeBag)

            expect(response).toEventuallyNot(beNil())
            expect(response?.totalCount).toEventually(equal(2))
            expect(response?.filters.count).toEventually(equal(2))
            expect(response?.filters[0].name).toEventually(equal("name0"))
            expect(response?.filters[0].title).toEventually(equal("title0"))
            expect(response?.filters[1].name).toEventually(equal("name1"))
            expect(response?.filters[1].title).toEventually(equal("title1"))
        }

        it("sends an error if the network returns incorrect data.") {
            
            var error: NetworkError? = nil
            let filtersService = FiltersService(network: FailureStubNetwork())

            filtersService.getFilters()
                .subscribe ({ e in
                    error = e.error as? NetworkError
                }).disposed(by: self.disposeBag)

            expect(error).toEventually(equal(NetworkError.IncorrectDataReturned))
        }

        it("passes the error sent by the network.") {
            
            var error: NetworkError? = nil
            let filtersService = FiltersService(network: ErrorStubNetwork())
            filtersService.getFilters()
                .subscribe ({ e in
                    error = e.error as? NetworkError
                }).disposed(by: self.disposeBag)

            expect(error).toEventually(equal(NetworkError.NotConnectedToInternet))
        }
    }
}
