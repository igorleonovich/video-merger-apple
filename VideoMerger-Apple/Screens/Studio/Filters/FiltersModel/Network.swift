//
//  Network.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import Alamofire
import Foundation
import RxSwift

public final class Network: Networking {

    private let queue = DispatchQueue(label: "videomerger.queue.network")

    public init() {}

    public func requestJSON(url: String, parameters: [String : Any]?) -> Observable<Any> {
        
        return Observable.create { observer -> Disposable in
            AF.request(url,
                       method: .get,
                       parameters: parameters,
                       encoding: URLEncoding.default,
                       headers: nil,
                       interceptor: nil
            ).responseJSON(queue: self.queue) { response in
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(NetworkError(error: error as NSError))
                }
            }

            return Disposables.create()
        }
    }
}
