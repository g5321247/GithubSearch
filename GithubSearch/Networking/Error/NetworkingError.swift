//
//  NetworkingError.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/8.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

enum NetworkingError: Error {
    case responseFaild(reason: ResponseErrorReason)
    case requestFaild(reason: RequestErrorReason)

    enum ResponseErrorReason: Error {
        case nilData
        case nonHTTPResponse
        case dataParsingFailed(reason: String)
        case apiError(statusCode: Int)
    }

    enum RequestErrorReason: Error {
        case invalidURL
        case missingURL
        case connectionFaild
    }
}
