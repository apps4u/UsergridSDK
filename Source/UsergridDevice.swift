//
//  UsergridDevice.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/23/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation
import UIKit
import Security

/**
`UsergridDevice` encapsulates information about the current device as well as stores information about push tokens and Usergrid notifiers.
*/
public class UsergridDevice : NSObject {

    /// The `UsergridDevice` type.
    static let USERGRID_DEVICE_TYPE = "device"

    // MARK: - Instance Properties -

    private(set) var deviceEntityDict: [String:AnyObject] = [:]

    /// The device UUID.
    public var UUID: String { return deviceEntityDict[UsergridEntityProperties.UUID.stringValue] as! String }

    /// The device model.
    public var model: String { return deviceEntityDict[USERGRID_DEVICE_MODEL] as! String }

    /// The device platform.
    public var platform: String { return deviceEntityDict[USERGRID_DEVICE_PLATFORM] as! String }

    /// The device operating system version.
    public var osVersion: String { return deviceEntityDict[USERGRID_DEVICE_OSVERSION] as! String }

    // MARK: - Initialization -

    /// The shared instance of `UsergridDevice`.
    public static var sharedDevice: UsergridDevice = UsergridDevice()

    /**
    Designated Initializer for `UsergridDevice` objects
    
    Most likely you will never need to create seperate instances of `UsergridDevice`.  Use of `UsergridDevice.sharedInstance` is recommended.

    - returns: A new instance of `UsergridDevice`.
    */
    override public init() {
        super.init()
        deviceEntityDict[UsergridEntityProperties.EntityType.stringValue] = UsergridDevice.USERGRID_DEVICE_TYPE
        deviceEntityDict[UsergridEntityProperties.UUID.stringValue] = UsergridDevice.usergridDeviceUUID()
        deviceEntityDict[USERGRID_DEVICE_MODEL] = UIDevice.currentDevice().model
        deviceEntityDict[USERGRID_DEVICE_PLATFORM] = UIDevice.currentDevice().systemName
        deviceEntityDict[USERGRID_DEVICE_OSVERSION] = UIDevice.currentDevice().systemVersion
    }

    // MARK: - Instance Methods -

    /**
    Sets the push token for the given notifier ID.
    
    This does not perform any API requests to update on Usergrid, rather it will just set the information in the `UsergridDevice` instance.
    
    In order to set the push token and perform an API request, use `UsergridClient.applyPushToken`.

    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The notifier ID.
    */
    public func applyPushToken(pushToken: NSData, notifierID: String) {
        deviceEntityDict[notifierID + USERGRID_NOTIFIER_ID_SUFFIX] = pushToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
    }

    private static func keychainItem() -> [String:AnyObject] {
        var keychainItem: [String:AnyObject] = [:]
        keychainItem[kSecClass as String] = kSecClassGenericPassword as String
        keychainItem[kSecAttrAccessible as String] = kSecAttrAccessibleAlways as String
        keychainItem[kSecAttrAccount as String] = USERGRID_KEYCHAIN_NAME
        keychainItem[kSecAttrService as String] = USERGRID_KEYCHAIN_SERVICE
        return keychainItem
    }

    private static func createNewUsergridKeychainUUID() -> String {
        let usergridUUID = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? NSUUID().UUIDString
        var keychainItem = UsergridDevice.keychainItem()
        keychainItem[kSecValueData as String] = (usergridUUID as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        SecItemAdd(keychainItem, nil)
        return usergridUUID
    }

    private static func usergridDeviceUUID() -> String {
        var queryAttributes = UsergridDevice.keychainItem()
        queryAttributes[kSecReturnData as String] = kCFBooleanTrue as Bool
        queryAttributes[kSecReturnAttributes as String] = kCFBooleanTrue as Bool
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(queryAttributes, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            if let resultDictionary = result as? NSDictionary {
                if let resultData = resultDictionary[kSecValueData as String] as? NSData {
                    if let keychainUUID = String(data: resultData, encoding: NSUTF8StringEncoding) {
                        return keychainUUID
                    }
                }
            }
        }
        return UsergridDevice.createNewUsergridKeychainUUID()
    }
}

private let USERGRID_KEYCHAIN_NAME = "Usergrid"
private let USERGRID_KEYCHAIN_SERVICE = "DeviceUUID"

private let USERGRID_DEVICE_MODEL = "deviceModel"
private let USERGRID_DEVICE_PLATFORM = "devicePlatform"
private let USERGRID_DEVICE_OSVERSION = "devicePlatform"

private let USERGRID_NOTIFIER_ID_SUFFIX = ".notifier.id"
