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

private let GRANT_TYPE = "grant_type"
private let TOKEN = "token"

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
        let requestURL = UsergridRequestManager.buildRequestURL(baseURL,paths:[TOKEN])
        let request = NSMutableURLRequest(URL: NSURL(string:requestURL)!)
        request.HTTPMethod = UsergridRequestManager.HttpMethod.POST.stringValue

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(self.jsonBodyDict, options: NSJSONWritingOptions())
        request.HTTPBody = jsonData
        request.setValue(String(format: "%lu", jsonData.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)

        return request
    }
}

public class UsergridUserAuth : NSObject, UsergridAuth {

    private static let PASSWORD = "password"
    private static let USERNAME = "username"

    public var accessToken : String?
    public var expiresIn : Int?

    public let username: String
    public let password: String

    public var jsonBodyDict: [String:AnyObject] {
        return [GRANT_TYPE:UsergridUserAuth.PASSWORD,
                UsergridUserAuth.USERNAME:self.username,
                UsergridUserAuth.PASSWORD:self.password]
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

    private static let CLIENT_CREDENTIALS = "client_credentials"
    private static let CLIENT_ID = "client_id"
    private static let CLIENT_SECRET = "client_secret"

    public var accessToken : String?
    public var expiresIn : Int?

    public let id: String
    public let secret: String

    public var jsonBodyDict: [String:AnyObject] {
        return [GRANT_TYPE:UsergridAppAuth.CLIENT_CREDENTIALS,
                UsergridAppAuth.CLIENT_ID:self.id,
                UsergridAppAuth.CLIENT_SECRET:self.secret]
    }
    
    public init(id:String,secret:String){
        self.id = id
        self.secret = secret
    }

    public class func auth(id id:String,secret:String) -> UsergridAppAuth {
        return UsergridAppAuth(id: id, secret: secret)
    }
}