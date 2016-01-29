//
//  UsergridKeychainHelpers.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 12/21/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#endif

private let USERGRID_KEYCHAIN_NAME = "Usergrid"
private let USERGRID_DEVICE_KEYCHAIN_SERVICE = "DeviceUUID"
private let USERGRID_CURRENT_USER_KEYCHAIN_SERVICE = "CurrentUser"

private func usergridGenericKeychainItem() -> [String:AnyObject] {
    var keychainItem: [String:AnyObject] = [:]
    keychainItem[kSecClass as String] = kSecClassGenericPassword as String
    keychainItem[kSecAttrAccessible as String] = kSecAttrAccessibleAlways as String
    keychainItem[kSecAttrAccount as String] = USERGRID_KEYCHAIN_NAME
    return keychainItem
}

internal extension UsergridDevice {

    static func deviceKeychainItem() -> [String:AnyObject] {
        var keychainItem = usergridGenericKeychainItem()
        keychainItem[kSecAttrService as String] = USERGRID_DEVICE_KEYCHAIN_SERVICE
        return keychainItem
    }

    static func createNewUsergridKeychainUUID() -> String {

        #if os(watchOS) || os(OSX)
            let usergridUUID = NSUUID().UUIDString
        #elseif os(iOS) || os(tvOS)
            let usergridUUID = UIDevice.currentDevice().identifierForVendor?.UUIDString ?? NSUUID().UUIDString
        #endif

        var keychainItem = UsergridDevice.deviceKeychainItem()
        keychainItem[kSecValueData as String] = (usergridUUID as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        SecItemAdd(keychainItem, nil)
        return usergridUUID
    }

    static func usergridDeviceUUID() -> String {
        var queryAttributes = UsergridDevice.deviceKeychainItem()
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

internal extension UsergridUser {

    static func userKeychainItem(client:UsergridClient) -> [String:AnyObject] {
        var keychainItem = usergridGenericKeychainItem()
        keychainItem[kSecAttrService as String] = USERGRID_CURRENT_USER_KEYCHAIN_SERVICE + "." + client.appId + "." + client.orgId
        return keychainItem
    }

    static func getCurrentUserFromKeychain(client:UsergridClient) -> UsergridUser? {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = kCFBooleanTrue as Bool
        queryAttributes[kSecReturnAttributes as String] = kCFBooleanTrue as Bool

        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(queryAttributes, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            if let resultDictionary = result as? NSDictionary {
                if let resultData = resultDictionary[kSecValueData as String] as? NSData {
                    if let currentUser = NSKeyedUnarchiver.unarchiveObjectWithData(resultData) as? UsergridUser {
                        return currentUser
                    }
                }
            }
        }
        return nil
    }

    static func saveCurrentUserKeychainItem(client:UsergridClient, currentUser:UsergridUser) {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = kCFBooleanTrue as Bool
        queryAttributes[kSecReturnAttributes as String] = kCFBooleanTrue as Bool

        if SecItemCopyMatching(queryAttributes,nil) == errSecSuccess // Do we need to update keychain item or add a new one.
        {
            let attributesToUpdate = [kSecValueData as String:NSKeyedArchiver.archivedDataWithRootObject(currentUser)]
            let updateStatus = SecItemUpdate(UsergridUser.userKeychainItem(client), attributesToUpdate)
            if updateStatus != errSecSuccess {
                print("Error updating current user data to keychain!")
            }
        }
        else
        {
            var keychainItem = UsergridUser.userKeychainItem(client)
            keychainItem[kSecValueData as String] = NSKeyedArchiver.archivedDataWithRootObject(currentUser)
            let status = SecItemAdd(keychainItem, nil)
            if status != errSecSuccess {
                print("Error adding current user data to keychain!")
            }
        }
    }

    static func deleteCurrentUserKeychainItem(client:UsergridClient) {
        var queryAttributes = UsergridUser.userKeychainItem(client)
        queryAttributes[kSecReturnData as String] = kCFBooleanFalse as Bool
        queryAttributes[kSecReturnAttributes as String] = kCFBooleanFalse as Bool
        if SecItemCopyMatching(queryAttributes,nil) == errSecSuccess {
            let deleteStatus = SecItemDelete(queryAttributes)
            if deleteStatus != errSecSuccess {
                print("Error deleting current user data to keychain!")
            }
        }
    }
}
