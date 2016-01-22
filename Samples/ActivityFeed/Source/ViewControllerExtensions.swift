//
//  ViewController.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 11/19/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title title: String, message: String?, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: handler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

