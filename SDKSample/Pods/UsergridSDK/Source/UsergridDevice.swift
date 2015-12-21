//
//  UsergridDevice.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/23/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation
import UIKit

/**
`UsergridDevice` is an `UsergridEntity` subclass that encapsulates information about the current device as well as stores information about push tokens and Usergrid notifiers.

To apply push tokens for Usergrid notifiers use the `UsergridClient.applyPushToken` method.
*/
public class UsergridDevice : UsergridEntity {

    /// The `UsergridDevice` type.
    static let DEVICE_ENTITY_TYPE = "device"

    // MARK: - Instance Properties -

    /// Property helper method for the `UsergridDevice` objects `uuid`.
    override public var uuid: String { return super[UsergridEntityProperties.UUID.stringValue] as! String }

    /// Property helper method for the `UsergridDevice` objects device model.
    public var model: String { return super[UsergridDeviceProperties.Model.stringValue] as! String }

    /// Property helper method for the `UsergridDevice` objects device platform.
    public var platform: String { return super[UsergridDeviceProperties.Platform.stringValue] as! String }

    /// Property helper method for the `UsergridDevice` objects device operating system version.
    public var osVersion: String { return super[UsergridDeviceProperties.OSVersion.stringValue] as! String }

    // MARK: - Initialization -

    /// The shared instance of `UsergridDevice`.
    public static var sharedDevice: UsergridDevice = UsergridDevice()

    /**
    Designated Initializer for `UsergridDevice` objects
    
    Most likely you will never need to create seperate instances of `UsergridDevice`.  Use of `UsergridDevice.sharedInstance` is recommended.

    - returns: A new instance of `UsergridDevice`.
    */
    public init() {
        var deviceEntityDict: [String:AnyObject] = [:]
        deviceEntityDict[UsergridEntityProperties.EntityType.stringValue] = UsergridDevice.DEVICE_ENTITY_TYPE
        deviceEntityDict[UsergridEntityProperties.UUID.stringValue] = UsergridDevice.usergridDeviceUUID()
        deviceEntityDict[UsergridDeviceProperties.Model.stringValue] = UIDevice.currentDevice().model
        deviceEntityDict[UsergridDeviceProperties.Platform.stringValue] = UIDevice.currentDevice().systemName
        deviceEntityDict[UsergridDeviceProperties.OSVersion.stringValue] = UIDevice.currentDevice().systemVersion
        super.init(type: UsergridDevice.DEVICE_ENTITY_TYPE, name: nil, propertyDict: deviceEntityDict)
    }

    // MARK: - NSCoding -

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }

    /**
    Subscript for the `UsergridDevice` class. Note that all of the `UsergridDeviceProperties` are immutable.

    - Warning: When setting a properties value must be a valid JSON object.

    - Example usage:
        ```
        let uuid = usergridDevice["uuid"]
        ```
    */
    override public subscript(propertyName: String) -> AnyObject? {
        get {
            return super[propertyName]
        }
        set(propertyValue) {
            if UsergridDeviceProperties.fromString(propertyName) == nil {
                super[propertyName] = propertyValue
            }
        }
    }

    // MARK: - Push Token Handling -

    /**
    Sets the push token for the given notifier ID.

    This does not perform any API requests to update on Usergrid, rather it will just set the information in the `UsergridDevice` instance.

    In order to set the push token and perform an API request, use `UsergridClient.applyPushToken`.

    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The notifier ID.
    */
    internal func applyPushToken(pushToken: NSData, notifierID: String) {
        self[notifierID + USERGRID_NOTIFIER_ID_SUFFIX] = pushToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
    }
}

private let USERGRID_NOTIFIER_ID_SUFFIX = ".notifier.id"
