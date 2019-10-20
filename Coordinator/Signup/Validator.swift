//
//  Validator.swift
//  Coordinator
//
//  Created by Emil Doychinov on 10/13/19.
//  Copyright © 2019 Emil Doychinov. All rights reserved.
//

import Foundation

protocol Validatable {
    func isValid(input: String) -> Bool
}

struct EmailValidator: Validatable {
    func isValid(input: String) -> Bool {
        return  input.contains("@") &&  input.contains(".")
    }
}

struct PasswordValidator: Validatable {
    func isValid(input: String) -> Bool {
        return input.contains { $0.isLetter } && input.contains { $0.isNumber } && !input.contains { $0.isWhitespace }
    }
}

