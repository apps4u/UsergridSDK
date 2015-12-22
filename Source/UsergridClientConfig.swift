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
    public var orgID : String

    /// The application identifier.
    public var appID : String

    /// The base URL that all calls will be made with.
    public var baseURL: String = UsergridClient.DEFAULT_BASE_URL

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

    - parameter orgID: The organization identifier.
    - parameter appID: The application identifier.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public init(orgID: String, appID: String) {
        self.orgID = orgID
        self.appID = appID
    }

    /**
    Convenience initializer for `UsergridClientConfig`.

    - parameter orgID:   The organization identifier.
    - parameter appID:   The application identifier.
    - parameter baseURL: The base URL that all calls will be made with.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public convenience init(orgID: String, appID: String, baseURL:String) {
        self.init(orgID:orgID,appID:appID)
        self.baseURL = baseURL
    }

    /**
    Convenience initializer for `UsergridClientConfig`.

    - parameter orgID:        The organization identifier.
    - parameter appID:        The application identifier.
    - parameter baseURL:      The base URL that all calls will be made with.
    - parameter authFallback: The `UsergridAuthFallback` value used to determine what type of token will be sent, if any.
    - parameter appAuth:      The application level `UsergridAppAuth` object.

    - returns: A new instance of `UsergridClientConfig`.
    */
    public convenience init(orgID: String, appID: String, baseURL:String, authFallback:UsergridAuthFallback, appAuth:UsergridAppAuth? = nil) {
        self.init(orgID:orgID,appID:appID,baseURL:baseURL)
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
        guard   let appID = aDecoder.decodeObjectForKey("appID") as? String,
                let orgID = aDecoder.decodeObjectForKey("orgID") as? String,
                let baseURL = aDecoder.decodeObjectForKey("baseURL") as? String
        else {
            self.appID = ""
            self.orgID = ""
            super.init()
            return nil
        }
        self.appID = appID
        self.orgID = orgID
        self.baseURL = baseURL
        self.appAuth = aDecoder.decodeObjectForKey("appAuth") as? UsergridAppAuth
        self.authFallback = UsergridAuthFallback(rawValue:aDecoder.decodeIntegerForKey("authFallback")) ?? .App
        super.init()
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.appID, forKey: "appID")
        aCoder.encodeObject(self.orgID, forKey: "orgID")
        aCoder.encodeObject(self.baseURL, forKey: "baseURL")
        aCoder.encodeObject(self.appAuth, forKey: "appAuth")
        aCoder.encodeInteger(self.authFallback.rawValue, forKey: "authFallback")
    }
}
