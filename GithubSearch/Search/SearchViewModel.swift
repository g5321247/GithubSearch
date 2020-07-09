//
//  SearchViewModel.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/9.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SearchViewModelInputs {
    func searchUsers(queryKey: String)
}

protocol SearchViewModelOutputs {
    var items: [User] { get }
    var reloadData: Driver<Void> { get }
}

protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }

    private(set)var items: [User] = []
    var reloadData: Driver<Void> {
        return reloadDataSubject.asDriver(onErrorJustReturn: ())
    }

    // MARK: Private
    private let reloadDataSubject: PublishSubject<Void> = PublishSubject()
    private let bag = DisposeBag()

    private let networkingService: NetworkingService

    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }

    func searchUsers(queryKey: String) {
        let request = SearchRequest(parameters: .init(queryKey: queryKey))
        networkingService.send(request: request)
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (result) in
                self.items = result.0.items
                self.reloadDataSubject.onNext(())
            }).disposed(by: bag)
    }
}

