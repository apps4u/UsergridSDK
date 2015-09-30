//
//  UsergridClient.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/3/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public typealias UsergridResponseCompletionBlock = (response: UsergridResponse) -> Void

public class UsergridClient: NSObject {

    static let DEFAULT_BASE_URL = "https://api.usergrid.com"

    public let requestManager: UsergridRequestManager

    public enum Config : String {
        case appID; case orgID; case url; case authFallback
    }
    
    public enum AuthFallback : String {
        case NONE; case APP
    }

    public var appID : String = ""
    public var orgID : String = ""

    private(set) public var baseURL : String = DEFAULT_BASE_URL
    public var clientAppURL : String { return baseURL + UsergridRequestManager.FORWARD_SLASH + orgID + UsergridRequestManager.FORWARD_SLASH + appID }

    public var authFallback: AuthFallback = AuthFallback.APP

    public var appAuth: UsergridAppAuth?

    public var userAuth: UsergridUserAuth? { return self.currentUser?.auth }
    public var currentUser: UsergridUser?

    // MARK: - Initialization -

    override public init() {
        self.requestManager = UsergridRequestManager()
        super.init()
        self.requestManager.client = self
    }

    public func initialize(orgID : String, appID: String, url: String = DEFAULT_BASE_URL) -> Self {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = baseURL
        return self
    }

    public func initialize(configuration: [Config:AnyObject]) -> Self {
        if let appID = configuration[Config.appID] as? String {
            self.appID = appID
        }
        if let orgID = configuration[Config.orgID] as? String {
            self.orgID = orgID
        }
        if let baseURL = configuration[Config.url] as? String {
            self.baseURL = baseURL
        }
        if let authFallbackString = configuration[Config.authFallback] as? String, let authFallback = AuthFallback(rawValue: authFallbackString) {
            self.authFallback = authFallback
        }
        return self
    }
}

// MARK: - Authorization -
extension UsergridClient {

    public func authForRequests() -> UsergridAuth? {
        var usergridAuth: UsergridAuth?
        if let userAuth = self.userAuth where userAuth.tokenIsValid {
            usergridAuth = userAuth
        } else if self.authFallback == AuthFallback.APP, let appAuth = self.appAuth where appAuth.tokenIsValid {
            usergridAuth = appAuth
        }
        return usergridAuth
    }

    public func authenticateApp(appAuth: UsergridAppAuth? = nil, completion: UsergridAppAuthCompletionBlock) {
        if let appAuth = appAuth ?? self.appAuth {
            self.requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
                self?.appAuth = auth
                completion(auth: auth, error: error)
            }
        } else {
            completion(auth: appAuth, error: "No UsergridAppAuth found to authenticate with.")
        }
    }

    public func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser:Bool = true, completion: UsergridUserAuthCompletionBlock) {
        self.requestManager.performAuthRequest(userAuth:userAuth, request: userAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,user,error) in
            if setAsCurrentUser {
                self?.currentUser = user
            }
            completion(auth: auth, user: user, error: error)
        }
    }
}

// MARK: - GET -
extension UsergridClient {

    // GET a single Enitity of a given type with a specific UUID/name
    public func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletionBlock) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), method: .GET, completion: completion)
    }

    // GET Entities of a given type with an optional query
    public func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletionBlock) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), method: .GET, completion: completion)
    }
}

// MARK: - PUT -
extension UsergridClient {

    // PUT Updates an Enitity with the given type and UUID/name specified using the passed in jsonBody
    public func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates the passed in Enitity
    public func PUT(entity: UsergridEntity, completion: UsergridResponseCompletionBlock) {
        PUT(entity.type, jsonBody: entity.jsonObjectValue, completion: completion)
    }

    // PUT Updates an Enitity with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody
    public func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        if let uuidOrName = jsonBody[UsergridEntity.UsergridEntityProperties.UUID.stringValue] as? String ?? jsonBody[UsergridEntity.UsergridEntityProperties.Name.stringValue] as? String {
            PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
        } else {
            completion(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    // PUT Updates Enitities that fit the given query using the passed in jsonBody
    public func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletionBlock) {
        if let type = query.collectionName {
            PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), jsonBody: jsonBody, completion: queryCompletion)
        } else {
            queryCompletion(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    private func PUT(type: String, requestURL: String, jsonBody: [String:AnyObject], completion: UsergridResponseCompletionBlock) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            self.requestManager.performRequest(type,requestURL: requestURL,method: .PUT,headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER,body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }
}

// MARK: - POST -
extension UsergridClient {

    // POST Creates an Entity
    public func POST(entity:UsergridEntity, completion: UsergridResponseCompletionBlock) {
        POST(entity.type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [entity.type]), jsonBody: entity.jsonObjectValue, completion: completion)
    }

    // POST Creates an array of Entities. Each Enitity in the array much already have a type assinged.
    public func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletionBlock) {
        if let entityType = entities.first?.type {
            POST(entityType, jsonBodies: entities.map { return ($0).jsonObjectValue }, completion: entitiesCompletion)
        } else {
            entitiesCompletion(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    // POST Creates an Entity of the given type with the given jsonBody
    public func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an array of Entities while assinging the given type to them
    public func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletionBlock) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBodies, completion:completion)
    }

    // POST Creates an Enitity of the given type with a given name and the given jsonBody
    public func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletionBlock) {
        var jsonBodyWithName = jsonBody
        jsonBodyWithName[UsergridEntity.UsergridEntityProperties.Name.stringValue] = name
        POST(type, jsonBody: jsonBodyWithName,completion: completion)
    }

    private func POST(type: String, requestURL: String, jsonBody: AnyObject, completion: UsergridResponseCompletionBlock) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            self.requestManager.performRequest(type,requestURL: requestURL, method: .POST, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }
}

// MARK: - DELETE -
extension UsergridClient {

    public func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletionBlock) {
        if let uuidOrName = entity.uuid ?? entity.name?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) {
            DELETE(entity.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    public func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletionBlock) {
        if let type = query.collectionName {
            DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), completion: queryCompletion)
        } else {
            queryCompletion(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    public func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletionBlock) {
        DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL, paths: [type,uuidOrName]), completion: completion)
    }

    private func DELETE(type: String, requestURL:String, completion:UsergridResponseCompletionBlock) {
        self.requestManager.performRequest(type, requestURL: requestURL, method: .DELETE, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, completion: completion)
    }
}