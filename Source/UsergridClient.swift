//
//  UsergridClient.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/3/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class UsergridClient: NSObject {

    static let DEFAULT_BASE_URL = "https://api.usergrid.com"

    lazy private(set) internal var requestManager: UsergridRequestManager = UsergridRequestManager(client: self)

    public let appID : String
    public let orgID : String

    public let baseURL : String
    public var clientAppURL : String { return "\(baseURL)/\(orgID)/\(appID)" }

    internal(set) public var currentUser: UsergridUser? = nil

    public var appAuth: UsergridAppAuth? = nil
    public var userAuth: UsergridUserAuth? { return currentUser?.auth }
    public var authFallback: UsergridAuthFallback = .App

    // MARK: - Initialization -

    public init(orgID: String, appID:String) {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = UsergridClient.DEFAULT_BASE_URL
        super.init()
    }

    public init(orgID: String, appID:String, baseURL:String) {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = baseURL
        super.init()
    }

    public init(configuration:UsergridClientConfig) {
        self.orgID = configuration.orgID
        self.appID = configuration.appID
        self.baseURL = configuration.baseURL
        self.authFallback = configuration.authFallback
        self.appAuth = configuration.appAuth
    }
}

// MARK: - Authorization -
extension UsergridClient {

    public func authForRequests() -> UsergridAuth? {
        var usergridAuth: UsergridAuth?
        if let userAuth = self.userAuth where userAuth.tokenIsValid {
            usergridAuth = userAuth
        } else if self.authFallback == .App, let appAuth = self.appAuth where appAuth.tokenIsValid {
            usergridAuth = appAuth
        }
        return usergridAuth
    }

    public func authenticateApp(completion: UsergridAppAuthCompletionBlock?) {
        if let appAuth = self.appAuth {
            self.requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
                self?.appAuth = auth
                completion?(auth: auth, error: error)
            }
        } else {
            completion?(auth: nil, error: "UsergridClient's appAuth is nil.")
        }
    }

    public func authenticateApp(appAuth: UsergridAppAuth, completion: UsergridAppAuthCompletionBlock?) {
        self.requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
            self?.appAuth = auth
            completion?(auth: auth, error: error)
        }
    }

    public func authenticateUser(userAuth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock?) {
        self.authenticateUser(userAuth, setAsCurrentUser:true, completion:completion)
    }

    public func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser: Bool, completion: UsergridUserAuthCompletionBlock?) {
        self.requestManager.performAuthRequest(userAuth:userAuth, request: userAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,user,error) in
            if setAsCurrentUser {
                self?.currentUser = user
            }
            completion?(auth: auth, user: user, error: error)
        }
    }

    public func logoutCurrentUser(completion:UsergridResponseCompletion?) {
        if let user = self.currentUser, uuidOrUsername = user.uuidOrUsername, token = user.auth?.accessToken {
            self.logoutUser(uuidOrUsername, token: token) { (response) -> Void in
                self.currentUser?.auth = nil
                self.currentUser = nil
                completion?(response: response)
            }
        } else {
            completion?(response:UsergridResponse(client: self, errorName: "Logout Failed.", errorDescription: "UsergridClient's currentUser is not valid."))
        }
    }

    public func logoutUserAllTokens(uuidOrUsername:String, completion:UsergridResponseCompletion?) {
        self.logoutUser(uuidOrUsername, token: nil, completion: completion)
    }

    public func logoutUser(uuidOrUsername:String, token:String?, completion:UsergridResponseCompletion?) {
        self.requestManager.performLogoutUserRequest(uuidOrUsername: uuidOrUsername, token:token, completion: completion)
    }
}

// MARK: - GET -
extension UsergridClient {

    // GET a single Enitity of a given type with a specific UUID/name
    public func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), method: .GET, completion: completion)
    }

    // GET Entities of a given type with an optional query
    public func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), method: .GET, completion: completion)
    }
}

// MARK: - PUT -
extension UsergridClient {

    // PUT Updates an Enitity with the given type and UUID/name specified using the passed in jsonBody
    public func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
    }

    // PUT Updates the passed in Enitity
    public func PUT(entity: UsergridEntity, completion: UsergridResponseCompletion?) {
        PUT(entity.type, jsonBody: entity.jsonObjectValue, completion: completion)
    }

    // PUT Updates an Enitity with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody
    public func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        if let uuidOrName = jsonBody[UsergridEntity.UsergridEntityProperties.UUID.stringValue] as? String ?? jsonBody[UsergridEntity.UsergridEntityProperties.Name.stringValue] as? String {
            PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    // PUT Updates Enitities that fit the given query using the passed in jsonBody
    public func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletion?) {
        if let type = query.collectionName {
            PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), jsonBody: jsonBody, completion: queryCompletion)
        } else {
            queryCompletion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    private func PUT(type: String, requestURL: String, jsonBody: [String:AnyObject], completion: UsergridResponseCompletion?) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            self.requestManager.performRequest(type,requestURL: requestURL,method: .PUT,headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER,body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion?(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }
}

// MARK: - POST -
extension UsergridClient {

    // POST Creates an Entity
    public func POST(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        POST(entity.type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [entity.type]), jsonBody: entity.jsonObjectValue, completion: completion)
    }

    // POST Creates an array of Entities. Each Enitity in the array much already have a type assinged.
    public func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletion?) {
        if let entityType = entities.first?.type {
            POST(entityType, jsonBodies: entities.map { return ($0).jsonObjectValue }, completion: entitiesCompletion)
        } else {
            entitiesCompletion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    // POST Creates an Entity of the given type with the given jsonBody
    public func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBody, completion: completion)
    }

    // POST Creates an array of Entities while assinging the given type to them
    public func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletion?) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBodies, completion:completion)
    }

    // POST Creates an Enitity of the given type with a given name and the given jsonBody
    public func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        var jsonBodyWithName = jsonBody
        jsonBodyWithName[UsergridEntity.UsergridEntityProperties.Name.stringValue] = name
        POST(type, jsonBody: jsonBodyWithName,completion: completion)
    }

    private func POST(type: String, requestURL: String, jsonBody: AnyObject, completion: UsergridResponseCompletion?) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            self.requestManager.performRequest(type,requestURL: requestURL, method: .POST, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion?(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }
}

// MARK: - DELETE -
extension UsergridClient {

    public func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        if let uuidOrName = entity.uuid ?? entity.name?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) {
            DELETE(entity.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    public func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletion?) {
        if let type = query.collectionName {
            DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), completion: queryCompletion)
        } else {
            queryCompletion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    public func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL, paths: [type,uuidOrName]), completion: completion)
    }

    private func DELETE(type: String, requestURL:String, completion:UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: requestURL, method: .DELETE, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, completion: completion)
    }
}

// MARK: - Entity Connections -
extension UsergridClient {

    public func CONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        requestManager.performConnect(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    public func DISCONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        requestManager.performDisconnect(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }
}

// MARK: - Asset Management - 
extension UsergridClient {

    public func uploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        self.requestManager.performUploadAsset(entity, asset: asset, progress:progress) { [weak entity] (response, asset, error) -> Void in
            entity?.asset = asset
            completion?(response: response, asset: asset, error: error)
        }
    }

    public func downloadAsset(entity:UsergridEntity, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        if entity.hasAsset {
            self.requestManager.performGetAsset(entity, contentType: contentType, progress:progress) { (asset, error) -> Void in
                completion?(asset: asset, error: error)
            }
        } else {
            completion?(asset: nil, error: "Entity does not have an asset attached.")
        }
    }
}