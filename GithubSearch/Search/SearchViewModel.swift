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
    func loadMore()
}

protocol SearchViewModelOutputs {
    var items: [User] { get }
    var shouldLoadMore: Bool { get }
    var showErrorMessage: Driver<String> { get }
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
    private(set)var shouldLoadMore: Bool = true
    var reloadData: Driver<Void> {
        return reloadDataSubject.asDriver(onErrorJustReturn: ())
    }

    var showErrorMessage: Driver<String> {
        return showErrorMessageSubject.asDriver(onErrorJustReturn: "")
    }

    // MARK: Private
    private let reloadDataSubject: PublishSubject<Void> = PublishSubject()
    private let showErrorMessageSubject: PublishSubject<String> = PublishSubject()
    private let bag = DisposeBag()
    private var nextPage: String = "0"
    private var queryKey = ""

    private let networkingService: NetworkingService

    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }

    func searchUsers(queryKey: String) {
        self.queryKey = queryKey
        let request = SearchRequest(parameters: .init(queryKey: self.queryKey, page: nextPage))
        networkingService.send(request: request)
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (result) in
                self.items = result.0.items
                self.handleHeaderLink(with: result.1.allHeaderFields["Link"] as? String)
                self.reloadDataSubject.onNext(())
            }, onError: { (_) in
                self.showErrorMessageSubject.onNext("連線錯誤")
            }).disposed(by: bag)
    }

    private func handleHeaderLink(with link: String?) {
        guard let link = link else { return }
        let links = link.components(separatedBy: ",")
        var dictionary: [String: String] = [:]
        links.forEach({
            let components = $0.components(separatedBy:"; ")
            var cleanPath = components[0].replacingOccurrences(of: " ", with: "")
            cleanPath = cleanPath.trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
            dictionary[components[1]] = cleanPath
        })
        if let nextPagePath = dictionary["rel=\"next\""] {
            guard let url = URL(string: nextPagePath),
                let page = url.queryParameters?["page"] else {
                return
            }
            self.nextPage = page
        }

        if dictionary["rel=\"last\""] != nil {
            shouldLoadMore = true
        }

    }

    func loadMore() {
        let request = SearchRequest(parameters: .init(queryKey: self.queryKey, page: nextPage))
        networkingService.send(request: request)
            .subscribe(onNext: { (result) in
                self.items.append(contentsOf: result.0.items)
                self.handleHeaderLink(with: result.1.allHeaderFields["Link"] as? String)
                self.reloadDataSubject.onNext(())
            }, onError: { (_) in
                self.showErrorMessageSubject.onNext("連線錯誤")
            }).disposed(by: bag)
    }
}
