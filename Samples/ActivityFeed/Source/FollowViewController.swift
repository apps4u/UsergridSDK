//
//  FollowViewController.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 1/21/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

class FollowViewController : UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!

    @IBAction func addFollowerButtonTouched(sender:AnyObject?) {
        guard let username = usernameTextField.text where !username.isEmpty
        else {
            self.showAlert(title: "Follow failed.", message: "Please enter a valid username.")
            return
        }

        UsergridManager.followUser(username) { (response) -> Void in
            if response.ok {
                self.performSegueWithIdentifier("unwindToChatSegue", sender: self)
            } else {
                self.showAlert(title: "Follow failed.", message: "No user with the username \"\(username)\" found.")
            }
        }
    }
}