//
//  InterfaceController.swift
//  WatchSample Extension
//
//  Created by Robert Walsh on 1/19/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import WatchKit
import Foundation
import UsergridSDK
import WatchConnectivity

class InterfaceController: WKInterfaceController,WCSessionDelegate {

    @IBOutlet var messageTable: WKInterfaceTable!

    static let MESSAGE_ENTITY_TYPE = "sdkmessage"
    static let MESSAGE_ENTITY_CREATOR = "creator"
    static let MESSAGE_ENTITY_TEXT = "text"

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle("Chit-Chat")
        UsergridManager.initializeSharedInstance()
        self.reloadTable()
    }

    func reloadTable() {
        UsergridManager.getMessages { (response) -> Void in
            self.messageTable.setNumberOfRows(response.count, withRowType: "MessageRow")
            if let entities = response.entities {
                for index in 0..<self.messageTable.numberOfRows {
                    if let controller = self.messageTable.rowControllerAtIndex(index) as? MessageRowController {
                        let messageEntity = entities[index]
                        controller.titleLabel.setText(messageEntity[InterfaceController.MESSAGE_ENTITY_CREATOR] as? String)
                        controller.messageLabel.setText(messageEntity[InterfaceController.MESSAGE_ENTITY_TEXT] as? String)
                    }
                }
            }
        }
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let action = message["action"] as? String where action == "reload" {
            self.reloadTable()
        }
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let action = message["action"] as? String where action == "reload" {
            self.reloadTable()
            replyHandler(["didSucceed":true])
        } else {
            replyHandler(["didSucceed":false])
        }
    }

    override func willActivate() {
        self.reloadTable()
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

}
