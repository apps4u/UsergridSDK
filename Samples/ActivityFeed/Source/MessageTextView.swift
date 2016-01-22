//
//  MessageTextView.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 11/24/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation
import SlackTextViewController

class MessageTextView : SLKTextView {
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        self.backgroundColor = UIColor.whiteColor()
        self.placeholderColor = UIColor.lightGrayColor()
        self.placeholder = "Message"
        self.pastableMediaTypes = .None
        self.layer.borderColor = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0).CGColor
    }
}
