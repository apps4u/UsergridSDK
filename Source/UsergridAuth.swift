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

@objc public enum UsergridAuthFallback : Int {
    case None
    case App
}

struct UsergridAuthConstants {
    static let CLIENT_CREDENTIALS = "client_credentials"
    static let CLIENT_ID = "client_id"
    static let CLIENT_SECRET = "client_secret"

    static let PASSWORD = "password"
    static let TOKEN = "token"

    static let GRANT_TYPE = "grant_type"
    static let USERNAME = "username"
}

public protocol UsergridAuth {
    var accessToken: String? { get set }
    var expiresIn: Int?  { get set }

    var hasToken: Bool { get }
    var tokenIsValid: Bool { get }
    var isExpired: Bool { get }

    var jsonBodyDict: [String:AnyObject] { get }

    func buildAuthRequest(requestURL:String) -> NSURLRequest
}

public extension UsergridAuth  {

    public var hasToken: Bool { return self.accessToken != nil }

    public var tokenIsValid : Bool { return self.hasToken && !self.isExpired }

    public var isExpired: Bool {
        var isExpired = true
        if let expires = self.expiresIn {
            isExpired = NSDate().compare(NSDate(utcTimeStamp: expires.description)) != NSComparisonResult.OrderedDescending
        }
        return isExpired
    }

    public func buildAuthRequest(baseURL:String) -> NSURLRequest {
        let requestURL = UsergridRequestManager.buildRequestURL(baseURL,paths:[UsergridAuthConstants.TOKEN])
        let request = NSMutableURLRequest(URL: NSURL(string:requestURL)!)
        request.HTTPMethod = UsergridHttpMethod.POST.rawValue

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(self.jsonBodyDict, options: NSJSONWritingOptions())
        request.HTTPBody = jsonData
        request.setValue(String(format: "%lu", jsonData.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)

        return request
    }
}

public class UsergridUserAuth : NSObject, UsergridAuth {

    public var accessToken : String?
    public var expiresIn : Int?

    public let username: String
    public let password: String

    public var jsonBodyDict: [String:AnyObject] {
        return [UsergridAuthConstants.GRANT_TYPE:UsergridAuthConstants.PASSWORD,
                UsergridAuthConstants.USERNAME:self.username,
                UsergridAuthConstants.PASSWORD:self.password]
    }

    public init(username:String, password: String){
        self.username = username
        self.password = password
    }

    public class func auth(username username:String, password: String) -> UsergridUserAuth {
        return UsergridUserAuth(username: username, password: password)
    }
}

public class UsergridAppAuth : NSObject, UsergridAuth {

    public var accessToken : String?
    public var expiresIn : Int?

    public let clientID: String
    public let clientSecret: String

    public var jsonBodyDict: [String:AnyObject] {
        return [UsergridAuthConstants.GRANT_TYPE:UsergridAuthConstants.CLIENT_CREDENTIALS,
                UsergridAuthConstants.CLIENT_ID:self.clientID,
                UsergridAuthConstants.CLIENT_SECRET:self.clientSecret]
    }
    
    public init(clientID:String,clientSecret:String){
        self.clientID = clientID
        self.clientSecret = clientSecret
    }

    public class func auth(clientID clientID:String,clientSecret:String) -> UsergridAppAuth {
        return UsergridAppAuth(clientID: clientID, clientSecret: clientSecret)
    }
}