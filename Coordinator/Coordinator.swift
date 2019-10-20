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
    init(with navigationController: UINavigationController)
}

class Coordinator: Coordinating {
    
    private unowned let navigationController: UINavigationController
    
    required init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let signupViewController = Steps.signup.viewController as? SignupViewController else { return }
        signupViewController.delegate = self
        navigationController.pushViewController(signupViewController, animated: true)
    }
}

extension Coordinator: SignupViewControllerDelegate {
    func signup(with email: String, password: String) {
        //WIP coordinate buttonModel state, send request via NetowrkingManger
    }
}
