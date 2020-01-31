//
//  NetworkingManager.swift
//  Coordinator
//
//  Created by Emil Doychinov on 10/17/19.
//  Copyright © 2019 Emil Doychinov. All rights reserved.
//

import Foundation
import Combine
enum httpMethod {
    case get, post, put
}

enum HTTPError: LocalizedError {
    case code
}


enum route {
    case signup(email: String, password: String)
    case search(term: String)
    
    var path: URL  {
        switch self {
        case .signup(_, _):
            return URL(string: "http://www.mocky.io/v2/5e3434423000008245d96381?mocky-delay=1000ms")!
        case .search(_):
            return URL(string: "")!
        }
    }
    
    var method: httpMethod {
        switch self {
        case .signup(_, _):
            return .put
        case .search(_):
            return .get
        }
    }
}

protocol UrlSessionProvider {
    func request(for url:URL) -> AnyPublisher<Data, HTTPError>
}

protocol NetworkingProvider {
    init(with session: UrlSessionProvider)
    func request<T: Codable>(route: route, result: @escaping (Result<T, Error>) -> ())
    func combineRequest<T: Codable, D: Codable>(route: (route, route), result: @escaping (Result<(T,D), Error>) -> Void)
}
 
class RequestManager: NetworkingProvider {
private let session: UrlSessionProvider!
    private var cancellableRequest: AnyCancellable?
    
    required init(with session: UrlSessionProvider = URLSession(configuration: .default) ) {
        self.session = session
    }

    func request<T: Codable>(route: route, result: @escaping (Result<T, Error>) -> ()) {
        cancellableRequest = session.request(for: route.path)
            .decode(type: T.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                   result(.failure(error))
                }
            }) { T in
                result(.success(T))
            }
    }
    
    func combineRequest<T: Codable, D: Codable>(route: (route, route), result: @escaping (Result<(T,D), Error>) -> Void) {
        let first = session.request(for: route.0.path)
            .decode(type: T.self, decoder: JSONDecoder())
        
        let second = session.request(for: route.1.path)
            .decode(type: D.self, decoder: JSONDecoder())
        
        _ = Publishers.Zip(first, second)
        .eraseToAnyPublisher()
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
               result(.failure(error))
            }
        }) { T in
            result(.success(T))
        }
    }
}

extension URLSession: UrlSessionProvider {
    func request(for url:URL) -> AnyPublisher<Data, HTTPError> {
        return dataTaskPublisher(for: url)
            .tryMap { stream in
                guard let httpResponse = stream.response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw HTTPError.code
                }
                return stream.data
            }
            .mapError { error in
                return HTTPError.code
            }
            .eraseToAnyPublisher()
    }
}
