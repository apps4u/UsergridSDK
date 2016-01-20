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
    var messageEntities: [UsergridEntity] = []

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.setTitle("Chit-Chat")
        if WCSession.isSupported() {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
    }

    override func willActivate() {
        self.reloadTable()
        if WCSession.defaultSession().reachable {
            WCSession.defaultSession().sendMessage(["action":"getMessages"], replyHandler: nil) { (error) -> Void in
                print(error)
            }
        }
        super.willActivate()
    }

    func reloadTable() {
        self.messageTable.setNumberOfRows(messageEntities.count, withRowType: "MessageRow")
        for index in 0..<self.messageTable.numberOfRows {
            if let controller = self.messageTable.rowControllerAtIndex(index) as? MessageRowController {
                let messageEntity = messageEntities[index]
                let messageInfo = UsergridManager.getMessageInfoFromEntity(messageEntity)
                controller.titleLabel.setText(messageInfo.displayName)
                controller.messageLabel.setText(messageInfo.content)
            }
        }
    }

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        if let messageEntities = NSKeyedUnarchiver.unarchiveObjectWithData(messageData) as? [UsergridEntity] {
            self.messageEntities = messageEntities
            self.reloadTable()
        }
    }

}
