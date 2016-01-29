//
//  ViewController.swift
//  Push
//
//  Created by Robert Walsh on 1/29/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func pushToThisDevice(sender: AnyObject) {
        UsergridManager.pushToThisDevice()
    }

    @IBAction func pushToAllDevices(sender: AnyObject) {
        UsergridManager.pushToAllDevices()
    }
}

