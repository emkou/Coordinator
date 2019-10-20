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

enum route {
    case signup(email: String, password: String)
    case search(term: String)
    
    var path: String  {
        switch self {
        case .signup(_, _):
            return ""
        case .search(_):
            return ""
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

protocol Session {
    func requestPublisher<T:Codable>(with: T) -> Publishers.Decode<Publishers.Map<URLSession.DataTaskPublisher, Data>, Array<T>, JSONDecoder>
}

protocol NetworkingProvider {
    init(with session: Session)
    func request(route: route, success: @escaping (Data) -> Void, failure: @escaping (Int) -> Void)
}
 
class NetworkingManager: NetworkingProvider {
private let session: Session!
    
    required init(with session: Session = URLSession(configuration: .default) ) {
        self.session = session
    }

    func request(route: route, success: @escaping (Data) -> Void, failure: @escaping (Int) -> Void) {
        session.requestPublisher(with: "")
        .replaceError(with: [])
        .eraseToAnyPublisher()
        .sink(receiveValue: { posts in
            print(posts.count)
        })
    }
}


extension URLSession: Session {
    func requestPublisher<T:Codable>(with: T) -> Publishers.Decode<Publishers.Map<URLSession.DataTaskPublisher, Data>, Array<T>, JSONDecoder> {
        return dataTaskPublisher(for: URL(string: "")!)
        .map { $0.data }
        .decode(type: [T].self, decoder: JSONDecoder())
    }
}
