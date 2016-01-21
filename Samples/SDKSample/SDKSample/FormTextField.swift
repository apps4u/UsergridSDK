//
//  FormTextField.swift
//  SDKSample
//
//  Created by Robert Walsh on 1/21/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class FormTextField: UITextField {

    @IBInspectable var inset: CGFloat = 0
    @IBOutlet weak var nextResponderField: UIResponder?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    func setUp() {
        addTarget(self, action: "actionKeyboardButtonTapped:", forControlEvents: .EditingDidEndOnExit)
    }

    func actionKeyboardButtonTapped(sender: UITextField) {
        switch nextResponderField {
        case let button as UIButton:
            if button.enabled {
                button.sendActionsForControlEvents(.TouchUpInside)
            } else {
                resignFirstResponder()
            }
        case .Some(let responder):
            responder.becomeFirstResponder()
        default:
            resignFirstResponder()
        }
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
