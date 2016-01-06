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
public class UsergridAuth : NSObject, NSCoding {

    // MARK: - Instance Properties -

    /// The access token, if this `UsergridAuth` was authorized successfully.
    public var accessToken : String?

    /// The expires at date, if this `UsergridAuth` was authorized successfully and their was a expires in time stamp within the token response.
    public var expiry : NSDate?

    /// Determines if an access token exists.
    public var hasToken: Bool { return self.accessToken != nil }

    /// Determines if an access token exists and if the token is not expired.
    public var isValid : Bool { return self.hasToken && !self.isExpired }

    /// Determines if the access token, if one exists, is expired.
    public var isExpired: Bool {
        var isExpired = true
        if let expires = self.expiry {
            isExpired = expires.timeIntervalSinceNow < 0.0
        }
        return isExpired
    }

    /// The credentials dictionary. Subclasses must override this method and provide an actual dictionary containing the credentials to send with requests.
    var credentialsJSONDict: [String:AnyObject] {
        return [:]
    }

    // MARK: - Initialization -

    /**
    Internal initialization method.  Note this should never be used outside of internal methods.

    - returns: A new instance of `UsergridAuth`.
    */
    override internal init() {
        super.init()
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        self.accessToken = aDecoder.decodeObjectForKey("accessToken") as? String
        self.expiry = aDecoder.decodeObjectForKey("expiry") as? NSDate
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encodeWithCoder(aCoder: NSCoder) {
        if let accessToken = self.accessToken {
            aCoder.encodeObject(accessToken, forKey: "accessToken")
        }
        if let expiresAt = self.expiry {
            aCoder.encodeObject(expiresAt, forKey: "expiry")
        }
    }

    /**
    Builds an authorization request which is can be used to retrieve the access token.

    - parameter baseUrl: The base URL of the access token request.

    - returns: A `NSURLRequest` object.
    */
    func buildAuthRequest(baseUrl:String) -> NSURLRequest {
        let requestURL = UsergridRequestManager.buildRequestURL(baseUrl,paths:["token"])
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
    private let password: String

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
        super.init()
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard let username = aDecoder.decodeObjectForKey("username") as? String,
                  password = aDecoder.decodeObjectForKey("password") as? String
        else {
            self.username = ""
            self.password = ""
            super.init(coder: aDecoder)
            return nil
        }

        self.username = username
        self.password = password
        super.init(coder: aDecoder)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    override public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.username, forKey: "username")
        aCoder.encodeObject(self.password, forKey: "password")
        super.encodeWithCoder(aCoder)
    }
}

/// The `UsergridAuth` subclass used for application level authorization.
public class UsergridAppAuth : UsergridAuth {

    // MARK: - Instance Properties -

    /// The client identifier associated with the application.
    public let clientId: String

    /// The client secret associated with the application.
    private let clientSecret: String

    /// The credentials dictionary constructed with the `UsergridAppAuth`'s `clientId` and `clientSecret`.
    override var credentialsJSONDict: [String:AnyObject] {
        return ["grant_type":"client_credentials",
                "client_id":self.clientId,
                "client_secret":self.clientSecret]
    }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridAppAuth` objects.

    - parameter clientId:     The client identifier associated with the application.
    - parameter clientSecret: The client secret associated with the application.

    - returns: A new instance of `UsergridAppAuth`.
    */
    public init(clientId:String,clientSecret:String){
        self.clientId = clientId
        self.clientSecret = clientSecret
        super.init()
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        if let clientId = aDecoder.decodeObjectForKey("clientId") as? String, clientSecret = aDecoder.decodeObjectForKey("clientSecret") as? String {
            self.clientId = clientId
            self.clientSecret = clientSecret
            super.init(coder: aDecoder)
        } else {
            self.clientId = ""
            self.clientSecret = ""
            super.init(coder: aDecoder)
            return nil
        }
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    override public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.clientId, forKey: "clientId")
        aCoder.encodeObject(self.clientSecret, forKey: "clientSecret")
        super.encodeWithCoder(aCoder)
    }
}