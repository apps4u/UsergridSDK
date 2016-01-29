//
//  UsergridClientConfig.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/5/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

/**
`UsergridClientConfig` is used when initializing `UsergridClient` objects.

The `UsergridClientConfig` is meant for further customization of `UsergridClient` objects when needed.
*/
public class UsergridClientConfig : NSObject, NSCoding {

    // MARK: - Instance Properties -

    /// The organization identifier.
    public var orgId : String

    /// The application identifier.
    public var appId : String

    /// The base URL that all calls will be made with.
    public var baseUrl: String = UsergridClient.DEFAULT_BASE_URL

    /// The `UsergridAuthFallback` value used to determine what type of token will be sent, if any.
    public var authFallback: UsergridAuthFallback = .App

    /** 
    The application level `UsergridAppAuth` object.
    
    Note that you still need to call the authentication methods within `UsergridClient` once it has been initialized.
    */
    public var appAuth: UsergridAppAuth?

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridClientConfig` objects.

    - parameter orgId: The organization identifier.
    - parameter appId: The application identifier.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public init(orgId: String, appId: String) {
        self.orgId = orgId
        self.appId = appId
    }

    /**
    Convenience initializer for `UsergridClientConfig`.

    - parameter orgId:   The organization identifier.
    - parameter appId:   The application identifier.
    - parameter baseUrl: The base URL that all calls will be made with.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public convenience init(orgId: String, appId: String, baseUrl:String) {
        self.init(orgId:orgId,appId:appId)
        self.baseUrl = baseUrl
    }

    /**
    Convenience initializer for `UsergridClientConfig`.

    - parameter orgId:        The organization identifier.
    - parameter appId:        The application identifier.
    - parameter baseUrl:      The base URL that all calls will be made with.
    - parameter authFallback: The `UsergridAuthFallback` value used to determine what type of token will be sent, if any.
    - parameter appAuth:      The application level `UsergridAppAuth` object.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public convenience init(orgId: String, appId: String, baseUrl:String, authFallback:UsergridAuthFallback, appAuth:UsergridAppAuth? = nil) {
        self.init(orgId:orgId,appId:appId,baseUrl:baseUrl)
        self.authFallback = authFallback
        self.appAuth = appAuth
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    public required init?(coder aDecoder: NSCoder) {
        guard   let appId = aDecoder.decodeObjectForKey("appId") as? String,
                let orgId = aDecoder.decodeObjectForKey("orgId") as? String,
                let baseUrl = aDecoder.decodeObjectForKey("baseUrl") as? String
        else {
            self.appId = ""
            self.orgId = ""
            super.init()
            return nil
        }
        self.appId = appId
        self.orgId = orgId
        self.baseUrl = baseUrl
        self.appAuth = aDecoder.decodeObjectForKey("appAuth") as? UsergridAppAuth
        self.authFallback = UsergridAuthFallback(rawValue:aDecoder.decodeIntegerForKey("authFallback")) ?? .App
        super.init()
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.appId, forKey: "appId")
        aCoder.encodeObject(self.orgId, forKey: "orgId")
        aCoder.encodeObject(self.baseUrl, forKey: "baseUrl")
        aCoder.encodeObject(self.appAuth, forKey: "appAuth")
        aCoder.encodeInteger(self.authFallback.rawValue, forKey: "authFallback")
    }
}