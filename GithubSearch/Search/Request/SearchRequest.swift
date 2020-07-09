//
//  SearchRequest.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/9.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct SearchRequest: Request {
    typealias Response = SearchResult
    let method: HTTPMethod = .get
    let path: String = "search/users"
    var parameter: [String : Any] {
        var dict: [String: Any] =  [
            "q": parameters.queryKey
        ]
        if parameters.page != "0" {
            dict["page"] = parameters.page
        }

        return dict
    }

    let parameters: Parameters

    struct Parameters {
        let queryKey: String
        let page: String
    }
}

struct SearchResult: Codable {
    let items: [User]
}

struct User: Codable {
    let name: String
    let picURLStr: String

    enum CodingKeys: String, CodingKey {
        case name = "login"
        case picURLStr = "avatar_url"
    }
}
