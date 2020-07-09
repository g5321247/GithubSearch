//
//  URLExtension.swift
//  GithubSearch
//
//  Created by 劉峻岫 on 2020/7/9.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
