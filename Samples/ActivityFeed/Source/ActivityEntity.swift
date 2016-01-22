//
//  ActivityEntity.swift
//  ActivityFeed
//
//  Created by Robert Walsh on 1/20/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation
import UsergridSDK

public class ActivityEntity: UsergridEntity {

    public var actor: [String:AnyObject]? { return self["actor"] as? [String:AnyObject] }

    public var content: String? { return self["content"] as? String }

    public var displayName: String? { return self.actor?["displayName"] as? String }

    public var email: String? { return self.actor?["email"] as? String }

    public var imageInfo: [String:AnyObject]? { return self.actor?["image"] as? [String:AnyObject] }

    public var imageURL: String? { return self.imageInfo?["url"] as? String }

    static func registerSubclass() {
        UsergridEntity.mapCustomType("activity", toSubclass: ActivityEntity.self)
    }

    required public init(type: String, name: String?, propertyDict: [String : AnyObject]?) {
        super.init(type: type, name: name, propertyDict: propertyDict)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
}