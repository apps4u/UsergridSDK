//
//  MessageEntity.swift
//  SDKSample
//
//  Created by Robert Walsh on 11/24/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

public class MessageEntity : UsergridEntity {

    public static let MESSAGE_TYPE = "sdkmessage"
    public static let MESSAGE_CREATOR = "creator"
    public static let MESSAGE_TEXT = "text"

    public var creator: String? {
        get { return self[MessageEntity.MESSAGE_CREATOR] as? String }
        set { self[MessageEntity.MESSAGE_CREATOR] = newValue }
    }

    public var text: String? {
        get { return self[MessageEntity.MESSAGE_TEXT] as? String }
        set { self[MessageEntity.MESSAGE_TEXT] = newValue }
    }

    convenience public init(creator: String, text: String) {
        self.init(type: MessageEntity.MESSAGE_TYPE, propertyDict:[MessageEntity.MESSAGE_CREATOR:creator,
                                                                  MessageEntity.MESSAGE_TEXT:text])
    }
}