//
//  UsergridDevice.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/23/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
import UIKit
#endif

#if os(watchOS)
import WatchKit
#endif

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

        #if os(iOS) || os(tvOS)
            deviceEntityDict[UsergridDeviceProperties.Model.stringValue] = UIDevice.currentDevice().model
            deviceEntityDict[UsergridDeviceProperties.Platform.stringValue] = UIDevice.currentDevice().systemName
            deviceEntityDict[UsergridDeviceProperties.OSVersion.stringValue] = UIDevice.currentDevice().systemVersion
        #elseif os(watchOS)
            deviceEntityDict[UsergridDeviceProperties.Model.stringValue] = WKInterfaceDevice.currentDevice().model
            deviceEntityDict[UsergridDeviceProperties.Platform.stringValue] = WKInterfaceDevice.currentDevice().systemName
            deviceEntityDict[UsergridDeviceProperties.OSVersion.stringValue] = WKInterfaceDevice.currentDevice().systemVersion
        #elseif os(OSX)
            deviceEntityDict[UsergridDeviceProperties.Model.stringValue] = "Mac"
            deviceEntityDict[UsergridDeviceProperties.Platform.stringValue] = "OSX"
            deviceEntityDict[UsergridDeviceProperties.OSVersion.stringValue] = NSProcessInfo.processInfo().operatingSystemVersionString
        #endif

        super.init(type: UsergridDevice.DEVICE_ENTITY_TYPE, name: nil, propertyDict: deviceEntityDict)
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /**
     The required public initializer for `UsergridEntity` subclasses.

     - parameter type:         The type associated with the `UsergridEntity` object.
     - parameter name:         The optional name associated with the `UsergridEntity` object.
     - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

     - returns: A new `UsergridDevice` object.
     */
    required public init(type: String, name: String?, propertyDict: [String : AnyObject]?) {
        super.init(type: type, name: name, propertyDict: propertyDict)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }

    // MARK: - Subclass Initialization -

    /**
    Required override for subclasses of UsergridEntity objects.

    In this method you will need to map the custom type with the type string returned from Usergrid using the `UsergridEntity.mapCustomType` method.
    */
    override public class func initialize() {
        UsergridEntity.mapCustomType(UsergridDevice.DEVICE_ENTITY_TYPE, toSubclass: UsergridDevice.self)
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
