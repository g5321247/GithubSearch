//
//  SearchViewModel.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/9.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

protocol SearchViewModelInputs {
    func searchUsers(queryKey: String)
}

protocol SearchViewModelOutputs {

}

protocol SearchViewModelType {
    var inputs: SearchViewModelInputs { get }
    var outputs: SearchViewModelOutputs { get }
}

class SearchViewModel: SearchViewModelType, SearchViewModelInputs, SearchViewModelOutputs {

    var inputs: SearchViewModelInputs { return self }
    var outputs: SearchViewModelOutputs { return self }

    private let networkingService: NetworkingService

    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }

    func searchUsers(queryKey: String) {
        let request = SearchRequest(parameters: .init(queryKey: queryKey))
        networkingService.send(request: request).subscribe(onNext: { (model) in
            print(model.0.itmes[0])
        })
    }
}

