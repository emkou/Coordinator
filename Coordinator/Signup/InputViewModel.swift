//
//  ViewModel.swift
//  Coordinator
//
//  Created by Emil Doychinov on 10/6/19.
//  Copyright © 2019 Emil Doychinov. All rights reserved.
//

import Foundation
import Combine

class InputViewModel {
    @Published var isValid: Bool = false
    @Published var text = ""
    
    private var cancellable: AnyCancellable?
    
    init(with validator: Validatable) {
        cancellable = $text
            .receive(on: DispatchQueue.main)
            .map { validator.isValid(input: $0) }
            .sink { [weak self] isValid in self?.isValid = isValid }
    }
}
