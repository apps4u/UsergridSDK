//
//  UsergridAuth.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/11/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

/// The completion block used in `UsergridAppAuth` authentication methods.
public typealias UsergridAppAuthCompletionBlock = (auth:UsergridAppAuth?, error: String?) -> Void

/// The completion block used in `UsergridUserAuth` authentication methods.
public typealias UsergridUserAuthCompletionBlock = (auth:UsergridUserAuth?, user:UsergridUser?, error: String?) -> Void

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
        let requestURL = UsergridRequestManager.buildRequestURL(baseURL,paths:["token"])
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
        return ["grant_type":"password",
                "username":self.username,
                "password":self.password]
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
        return ["grant_type":"client_credentials",
                "client_id":self.clientID,
                "client_secret":self.clientSecret]
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