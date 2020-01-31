//
//  ViewController.swift
//  Coordinator
//
//  Created by Emil Doychinov on 9/27/19.
//  Copyright © 2019 Emil Doychinov. All rights reserved.
//

import UIKit
import Foundation
import Combine

protocol SignupViewControllerDelegate: class {
    func signup(with email: String, password: String)
}

class SignupViewController: UIViewController {
    
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var emailCheckmark: UIImageView!
    
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var passwordCheckmark: UIImageView!
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private var passwordFieldVideModel = InputViewModel(with: PasswordValidator())
    private var emailFieldVideModel = InputViewModel(with: EmailValidator())

    private var combine: AnyCancellable?
    private var emailSubscriber: AnyCancellable?
    private var passwordSubscriber: AnyCancellable?
    private var emailFieldSubscriber: AnyCancellable?
    private var passwordFieldSubscriber: AnyCancellable?

    
    weak var delegate: SignupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTextFieldListeners()
        self.setupValidationListeners()
        
        //REMOVE OBSERVER and HIDE KEYBOARD
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupTextFieldListeners() {
        passwordFieldSubscriber = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: passwordField)
        .compactMap{ ($0.object as? UITextField)?.text }
        .debounce(for: 0.1, scheduler: RunLoop.main)
        .removeDuplicates()
        .assign(to: \InputViewModel.text, on: passwordFieldVideModel)
        
        emailFieldSubscriber = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: emailField)
        .compactMap{ ($0.object as? UITextField)?.text }
        .debounce(for: 0.1, scheduler: RunLoop.main)
        .removeDuplicates()
        .assign(to: \InputViewModel.text, on: emailFieldVideModel)
    }
    
    private func setupValidationListeners() {
        combine = Publishers.CombineLatest(emailFieldVideModel.$isValid, passwordFieldVideModel.$isValid)
                    .receive(on: DispatchQueue.main)
                    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
                    .map { one, two in (one && two) }
                    .assign(to: \.isEnabled, on: loginButton)
        
        emailSubscriber = emailFieldVideModel.$isValid
            .receive(on: DispatchQueue.main)
            .map{!$0}
            .assign(to: \.isHidden, on: emailCheckmark)
        
        passwordSubscriber = passwordFieldVideModel.$isValid
            .receive(on: DispatchQueue.main)
            .map{!$0}
            .assign(to: \.isHidden, on: passwordCheckmark)
    }
    
    @IBAction private func didPressSignup(_ sender: Any) {
        delegate?.signup(with: emailFieldVideModel.text, password: passwordFieldVideModel.text)
    }
    
    @objc private func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }

    @objc private func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


