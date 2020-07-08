//
//  Client.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/8.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation
import RxSwift

protocol Session {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: Session {}

protocol NetworkingService {
    func send<Res: Request> (
        request: Res,
        completion: @escaping (Result<(Res.Response, HTTPURLResponse), Error>) -> Void
    )

    func send<Res: PaginatableRequest>(request: Res) -> Observable<(Res.Response, HTTPURLResponse)>
}

class Client: NetworkingService {
    private let session: Session

    init(session: Session = URLSession.shared) {
        self.session = session
    }

    func send<Res: Request> (
        request: Res,
        completion: @escaping (Result<(Res.Response, HTTPURLResponse), Error>) -> Void
    ) {
        do {
            var request = request
            let urlRequest = try request.buildRequest()

            let dataTask = session.dataTask(with: urlRequest) { data, response, error in
                DispatchQueue.main.async {
                    guard let data = data else {
                        completion(
                            .failure(error ?? NetworkingError.responseFaild(reason: .nilData))
                        )
                        return
                    }
                    self.handle(data: data, response: response, request: request, completion: completion)
                }
            }

            dataTask.resume()
        } catch {
            completion(.failure(error))
        }
    }

    private func handle<Res: Request>(
        data: Data, response: URLResponse?, request: Res,
        completion: @escaping (Result<(Res.Response, HTTPURLResponse), Error>) -> Void
    ) {
        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkingError.responseFaild(reason: .nonHTTPResponse)))
            return
        }

        guard 200 ..< 300 ~= response.statusCode else {
            completion(.failure(
                NetworkingError.responseFaild(
                    reason: .apiError(statusCode: response.statusCode)
            )))
            return
        }

        do {
            let result = try JSONDecoder().decode(Res.Response.self, from: data)
            completion(.success((result, response)))
        } catch {
            #if DEBUG
            print("parse error: \(error)")
            #endif
            completion(.failure(
                NetworkingError.ResponseErrorReason.dataParsingFailed(
                    reason: "\(error)"
            )))
        }
    }

    func send<Res: Request>(request: Res) -> Observable<(Res.Response, HTTPURLResponse)> {
        return Observable<(Res.Response, HTTPURLResponse)>.create { observer in
            self.send(request: request) { result in
                switch result {
                case .success(let response):
                    observer.onNext(response)

                case .failure(let err):
                    observer.onError(err)
                }
            }

            return Disposables.create()
        }
    }
}
