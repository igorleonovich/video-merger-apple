//
//  FiltersService.swift
//  VideoMerger-Apple
//
//  Created by Igor Leonovich on 02/10/2023.
//

import RxSwift
import SwiftyJSON

public final class FiltersService: FiltersGetting {
    
    private let network: Networking
    
    public init(network: Networking) {
        self.network = network
    }

    public func getFilters() -> Observable<ResponseEntity> {
        
        let url = "\(Constants.baseUrl)/filters"
        return Observable.create { [weak self] observer -> Disposable in
            guard let self = self else {
                observer.onError(NetworkError.NotReachedServer)
                return Disposables.create()
            }

            return network.requestJSON(url: url, parameters: nil)
                .subscribe(onNext: { json in
                    if let response = try? ResponseEntity.decode(JSON(json)) {
                        observer.onNext(response)
                        return
                    }

                    observer.onError(NetworkError.IncorrectDataReturned)
                }, onError: { error in
                    observer.onError(error)
                })
        }
    }
}
