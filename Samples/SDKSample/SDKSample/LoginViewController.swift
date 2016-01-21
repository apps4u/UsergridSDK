//
//  LoginViewController.swift
//  SDKSample
//
//  Created by Robert Walsh on 1/21/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
    }

    override func viewDidAppear(animated: Bool) {
        Usergrid.logoutCurrentUser()
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }

    @IBAction func loginButtonTouched(sender: AnyObject) {
        guard let username = usernameTextField.text where !username.isEmpty,
              let password = passwordTextField.text where !password.isEmpty
        else {
            self.showAlert(title: "Error Authenticating User", message: "Username and password must not be empty.")
            return;
        }

        self.loginUser(username, password: password)
    }

    func loginUser(username:String, password:String) {
        UsergridManager.loginUser(username,password: password) { (auth, user, error) -> Void in
            if let authErrorDescription = error {
                self.showAlert(title: "Error Authenticating User", message: authErrorDescription)
            } else if let authenticatedUser = user {
                self.showAlert(title: "Authenticated User Successful", message: "User description: \n \(authenticatedUser.stringValue)") { (action) -> Void in
                    self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                }
            }
        }
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {
        // Used for unwind segues back to this view controller.
    }
}
