//
//  NetworkSpec.swift
//  VideoMerger-Apple-Tests
//
//  Created by Igor Leonovich on 11/10/2023.
//

import Alamofire
import Foundation
import Nimble
import Quick
import RxSwift

@testable import VideoMerger_Apple


final class NetworkSpec: QuickSpec {
    
    private static let timeoutSeconds = 5
    private static let timeout = DispatchTimeInterval.seconds(timeoutSeconds)
    
    private static let disposeBag = DisposeBag()
    
    
    // MARK: Spec
    
    override class func spec() {
        
        var network: Network!
        beforeEach {
            network = Network()
        }

        describe("JSON") {
            
            it("eventually gets JSON data as specified with parameters.") {
                
                var json: [String: Any]? = nil
                let url = "https://httpbin.org/get"
                network.requestJSON(url: url, parameters: ["a": "b", "x": "y"])
                    .subscribe(onNext: {
                        json = $0 as? [String: Any]
                    }).disposed(by: self.disposeBag)

                expect(json).toEventuallyNot(beNil(), timeout: .seconds(timeoutSeconds))
                expect((json?["args"] as? [String: AnyObject])?["a"] as? String)
                    .toEventually(equal("b"), timeout: .seconds(timeoutSeconds))
                expect((json?["args"] as? [String: AnyObject])?["x"] as? String)
                    .toEventually(equal("y"), timeout: .seconds(timeoutSeconds))
            }

            it("eventually gets an error if the network has a problem.") {
                
                var error: NetworkError? = nil
                let url = "https://not.existing.server.comm/get"
                network.requestJSON(url: url, parameters: ["a": "b", "x": "y"])
                    .subscribe ({ e in
                        error = e.error as? NetworkError
                    }).disposed(by: disposeBag)

                expect(error).toEventually(equal(NetworkError.Unknown), timeout: .seconds(timeoutSeconds))
            }
        }
    }
}
