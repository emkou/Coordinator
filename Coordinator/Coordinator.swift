//
//  Coordinator.swift
//  Coordinator
//
//  Created by Emil Doychinov on 10/5/19.
//  Copyright © 2019 Emil Doychinov. All rights reserved.
//

import Foundation
import UIKit

enum Steps: String {
    case signup
    case search
    
    var viewController: UIViewController? {
        return UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: self.rawValue) 
    }
}

protocol Coordinating {
    func start()
    init(with navigationController: UINavigationController, requestManager: NetworkingProvider)
}

class Coordinator: Coordinating {
    
    private unowned let navigationController: UINavigationController
    private var searchViewController: SearchViewController?
    private let requestManager: NetworkingProvider
    
    required init(with navigationController: UINavigationController, requestManager: NetworkingProvider) {
        self.navigationController = navigationController
        self.requestManager = requestManager
    }
    
    func start() {
        guard let signupViewController = Steps.signup.viewController as? SignupViewController else { return }
        signupViewController.delegate = self
        navigationController.pushViewController(signupViewController, animated: true)
    }
}

extension Coordinator: SignupViewControllerDelegate {
    func signup(with email: String, password: String) {
        requestManager.request(route: .signup(email: email, password: password)) { [weak self] ( result: Result<AppSession, Error>) in
            switch result {
            case .success(_):
                self?.searchViewController = Steps.search.viewController as? SearchViewController
                guard let searchViewController = self?.searchViewController else { return }
                searchViewController.delegate = self
                self?.navigationController.pushViewController(searchViewController, animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension Coordinator: SearchViewControllerDelegate {
    func search(text: String) {
            
    }
}
