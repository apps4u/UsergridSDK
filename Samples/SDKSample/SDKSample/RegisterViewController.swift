//
//  RegisterViewController.swift
//  SDKSample
//
//  Created by Robert Walsh on 1/21/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func registerButtonTouched(sender: AnyObject) {
        guard let name = nameTextField.text where !name.isEmpty,
              let username = usernameTextField.text where !username.isEmpty,
              let email = emailTextField.text where !email.isEmpty,
              let password = passwordTextField.text where !password.isEmpty
        else {
            self.showAlert(title: "Error Registering User", message: "Name, username, email, and password fields must not be empty.")
            return;
        }

        self.createUser(name, username: username, email: email, password: password)
    }

    private func createUser(name:String, username:String, email:String, password:String) {
        UsergridManager.createUser(name, username: username, email: email, password: password) { (response) -> Void in
            if let createdUser = response.user {
                self.showAlert(title: "Registering User Successful", message: "User description: \n \(createdUser.stringValue)") { (action) -> Void in
                    self.performSegueWithIdentifier("unwindSegue", sender: self)
                }
            } else {
                self.showAlert(title: "Error Registering User", message: response.error?.errorDescription)
            }
        }
    }
}
