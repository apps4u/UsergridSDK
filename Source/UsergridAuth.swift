//
//  UsergridAuth.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/11/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public typealias UsergridAppAuthCompletionBlock = (auth:UsergridAppAuth?, error: String?) -> Void
public typealias UsergridUserAuthCompletionBlock = (auth:UsergridUserAuth?, user:UsergridUser?, error: String?) -> Void

struct UsergridAuthConstants {
    static let CLIENT_CREDENTIALS = "client_credentials"
    static let CLIENT_ID = "client_id"
    static let CLIENT_SECRET = "client_secret"

    static let PASSWORD = "password"
    static let TOKEN = "token"

    static let GRANT_TYPE = "grant_type"
    static let USERNAME = "username"
}

/**
A enumeration that is used to determine what the `UsergridClient` will fallback to depending on certain authorization conditions.
*/
@objc public enum UsergridAuthFallback : Int {
    /**
    If a non-expired user auth token exists in `UsergridClient.currentUser`, this token is used to authenticate all API calls. 
    
    If the API call fails, the activity is treated as a failure with an appropriate HTTP status code.  
    
    If a non-expired user auth token does not exist, all API calls will be made unauthenticated.
    */
    case None
    /**
    If a non-expired user auth token exists in `UsergridClient.currentUser`, this token is used to authenticate all API calls. 
    
    If the API call fails, the activity is treated as a failure with an appropriate HTTP status code (This behavior is identical to authFallback=.None).
    
    If a non-expired user auth does not exist, all API calls will be made using stored app auth.
    */
    case App
}

/** 
The base class for `UsergridAppAuth` and `UsergridUserAuth` classes.

This class should never be initialized on its own.  The use of the `UsergridAppAuth` and `UsergridUserAuth` subclasses should be used.
*/
public class UsergridAuth : NSObject {

    // MARK: - Instance Properties -

    /// The access token, if this `UsergridAuth` was authorized successfully.
    public var accessToken : String?

    /// The expires in time stamp, if this `UsergridAuth` was authorized successfully and their was a expires in time stamp within the token response.
    public var expiresIn : Int?

    /// Determines if an access token exists.
    public var hasToken: Bool { return self.accessToken != nil }

    /// Determines if an access token exists and if the token is not expired.
    public var tokenIsValid : Bool { return self.hasToken && !self.isExpired }

    /// Determines if the access token, if one exists, is expired.
    public var isExpired: Bool {
        var isExpired = true
        if let expires = self.expiresIn {
            isExpired = NSDate().compare(NSDate(utcTimeStamp: expires.description)) != NSComparisonResult.OrderedDescending
        }
        return isExpired
    }

    var credentialsJSONDict: [String:AnyObject] {
        return [:]
    }

    /**
    Builds an authorization request which is can be used to retrieve the access token.

    - parameter baseURL: The base URL of the access token request.

    - returns: A `NSURLRequest` object.
    */
    func buildAuthRequest(baseURL:String) -> NSURLRequest {
        let requestURL = UsergridRequestManager.buildRequestURL(baseURL,paths:[UsergridAuthConstants.TOKEN])
        let request = NSMutableURLRequest(URL: NSURL(string:requestURL)!)
        request.HTTPMethod = UsergridHttpMethod.POST.rawValue

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(self.credentialsJSONDict, options: NSJSONWritingOptions())
        request.HTTPBody = jsonData
        request.setValue(String(format: "%lu", jsonData.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)

        return request
    }
}

/// The `UsergridAuth` subclass used for user level authorization.
public class UsergridUserAuth : UsergridAuth {

    // MARK: - Instance Properties -

    /// The username associated with the User.
    public let username: String

    /// The password associated with the User.
    public let password: String

    /// The credentials dictionary constructed with the `UsergridUserAuth`'s `username` and `password`.
    override var credentialsJSONDict: [String:AnyObject] {
        return [UsergridAuthConstants.GRANT_TYPE:UsergridAuthConstants.PASSWORD,
                UsergridAuthConstants.USERNAME:self.username,
                UsergridAuthConstants.PASSWORD:self.password]
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridUserAuth` objects.

    - parameter username: The username associated with the User.
    - parameter password: The password associated with the User.

    - returns: A new instance of `UsergridUserAuth`.
    */
    public init(username:String, password: String){
        self.username = username
        self.password = password
    }
}

/// The `UsergridAuth` subclass used for application level authorization.
public class UsergridAppAuth : UsergridAuth {

    // MARK: - Instance Properties -

    /// The client identifier associated with the application.
    public let clientID: String

    /// The client secret associated with the application.
    public let clientSecret: String

    /// The credentials dictionary constructed with the `UsergridAppAuth`'s `clientID` and `clientSecret`.
    override var credentialsJSONDict: [String:AnyObject] {
        return [UsergridAuthConstants.GRANT_TYPE:UsergridAuthConstants.CLIENT_CREDENTIALS,
                UsergridAuthConstants.CLIENT_ID:self.clientID,
                UsergridAuthConstants.CLIENT_SECRET:self.clientSecret]
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridAppAuth` objects.

    - parameter clientID:     The client identifier associated with the application.
    - parameter clientSecret: The client secret associated with the application.

    - returns: A new instance of `UsergridAppAuth`.
    */
    public init(clientID:String,clientSecret:String){
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}