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

    /**
    Initializes instances of `UsergridClient`.
    - parameter orgID: The organization identifier.
    - parameter appID: The application identifier.
    - returns: The new instance of `UsergridClient`.
    */
    public init(orgID: String, appID:String) {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = UsergridClient.DEFAULT_BASE_URL
        super.init()
    }

    /**
    Initializes instances of `UsergridClient`.
    - parameter orgID: The organization identifier.
    - parameter appID: The application identifier.
    - parameter baseURL: The base URL that all calls will be made with.
    - returns: The new instance of `UsergridClient`.
    */
    public init(orgID: String, appID:String, baseURL:String) {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = baseURL
        super.init()
    }

    /**
    Initializes instances of `UsergridClient`.
    - parameter configuration: The configuration for the client to be set up with.
    - returns: The new instance of `UsergridClient`.
    */
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

    // TODO: DOCUMENTATION
    public func authForRequests() -> UsergridAuth? {
        var usergridAuth: UsergridAuth?
        if let userAuth = self.userAuth where userAuth.tokenIsValid {
            usergridAuth = userAuth
        } else if self.authFallback == .App, let appAuth = self.appAuth where appAuth.tokenIsValid {
            usergridAuth = appAuth
        }
        return usergridAuth
    }

    /**
    Authenticates with the `UsergridAppAuth` that is contained this instance of `UsergridCient`.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
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

    /**
    Authenticates with the `UsergridAppAuth` that is passed in.
    - parameter auth: The `UsergridAppAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public func authenticateApp(appAuth: UsergridAppAuth, completion: UsergridAppAuthCompletionBlock?) {
        self.requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
            self?.appAuth = auth
            completion?(auth: auth, error: error)
        }
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in.
    - parameter auth: The `UsergridUserAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public func authenticateUser(userAuth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock?) {
        self.authenticateUser(userAuth, setAsCurrentUser:true, completion:completion)
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in.
    - parameter auth: The `UsergridUserAuth` that will be authenticated.
    - parameter setAsCurrentUser: If the authenticated user should be set as the `UsergridClient.currentUser`.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser: Bool, completion: UsergridUserAuthCompletionBlock?) {
        self.requestManager.performAuthRequest(userAuth:userAuth, request: userAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,user,error) in
            if setAsCurrentUser {
                self?.currentUser = user
            }
            completion?(auth: auth, user: user, error: error)
        }
    }

    // TODO: DOCUMENTATION
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

    // TODO: DOCUMENTATION
    public func logoutUserAllTokens(uuidOrUsername:String, completion:UsergridResponseCompletion?) {
        self.logoutUser(uuidOrUsername, token: nil, completion: completion)
    }

    // TODO: DOCUMENTATION
    public func logoutUser(uuidOrUsername:String, token:String?, completion:UsergridResponseCompletion?) {
        self.requestManager.performLogoutUserRequest(uuidOrUsername: uuidOrUsername, token:token, completion: completion)
    }
}

// MARK: - GET -
extension UsergridClient {

    /**
    Gets a single `UsergridEntity` of a given type with a specific UUID/name.
    - parameter type: The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), method: .GET, completion: completion)
    }

    /**
    Gets a group of `UsergridEntity` objects of a given type with an optional query.
    - parameter type: The `UsergridEntity` type.
    - parameter query: The optional query to use when gathering `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), method: .GET, completion: completion)
    }
}

// MARK: - PUT -
extension UsergridClient {

    /**
    Updates an `UsergridEntity` with the given type and UUID/name specified using the passed in jsonBody.
    - parameter type: The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter jsonBody: The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
    }

    /**
    Updates the passed in `UsergridEntity`.
    - parameter entity: The `UsergridEntity` to update.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func PUT(entity: UsergridEntity, completion: UsergridResponseCompletion?) {
        PUT(entity.type, jsonBody: entity.jsonObjectValue, completion: completion)
    }

    /**
    Updates an `UsergridEntity` with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody.
    - parameter type: The `UsergridEntity` type.
    - parameter jsonBody: The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        if let uuidOrName = jsonBody[UsergridEntity.UsergridEntityProperties.UUID.stringValue] as? String ?? jsonBody[UsergridEntity.UsergridEntityProperties.Name.stringValue] as? String {
            PUT(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    /**
    Updates the entities that fit the given query using the passed in jsonBody.
    - parameter query: The query to use when filtering what entities to update.
    - parameter jsonBody: The valid JSON body dictionary to update with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
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

    /**
    Creates and posts creates an `UsergridEntity`.
    - parameter entity: The `UsergridEntity` to create.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        POST(entity.type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [entity.type]), jsonBody: entity.jsonObjectValue, completion: completion)
    }

    /**
    Creates and posts an array of `UsergridEntity` objects.

    Each `UsergridEntity` in the array much already have a type assinged and must be the same.

    - parameter entities: The `UsergridEntity` objects to create.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletion?) {
        if let entityType = entities.first?.type {
            POST(entityType, jsonBodies: entities.map { return ($0).jsonObjectValue }, completion: entitiesCompletion)
        } else {
            entitiesCompletion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    /**
    Creates and posts an `UsergridEntity` of the given type with the given jsonBody.
    - parameter type: The `UsergridEntity` type.
    - parameter jsonBody: The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBody, completion: completion)
    }

    /**
    Creates and posts an array of `Entity` objects while assinging the given type to them.
    - parameter type: The `UsergridEntity` type.
    - parameter jsonBody: The valid JSON body dictionaries to use when creating the `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletion?) {
        POST(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBodies, completion:completion)
    }

    /**
    Creates and posts an `UsergridEntity` of the given type with a given name and the given jsonBody.
    - parameter type: The `UsergridEntity` type.
    - parameter name: The name of the `UsergridEntity`.
    - parameter jsonBody: The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
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

    /**
    Destroys the passed `UsergridEntity`.
    - parameter entity: The `UsergridEntity` to delete.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        if let uuidOrName = entity.uuid ?? entity.name?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) {
            DELETE(entity.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    /**
    Destroys the `UsergridEntity` objects that fit the given `UsergridQuery`.
    - parameter query: The query to use when filtering what entities to delete.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletion?) {
        if let type = query.collectionName {
            DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), completion: queryCompletion)
        } else {
            queryCompletion?(response: UsergridResponse(client:self, errorName: "", errorDescription: ""))
        }
    }

    /**
    Destroys the `UsergridEntity` of a given type with a specific UUID/name.
    - parameter type: The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        DELETE(type, requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL, paths: [type,uuidOrName]), completion: completion)
    }

    private func DELETE(type: String, requestURL:String, completion:UsergridResponseCompletion?) {
        self.requestManager.performRequest(type, requestURL: requestURL, method: .DELETE, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, completion: completion)
    }
}

// MARK: - Entity Connections -
extension UsergridClient {

    /**
    Connects the `UsergridEntity` objects via the relationship.
    - parameter entity: The `UsergridEntity` that will contain the connection.
    - parameter relationship: The relationship of the two entities.
    - parameter connectingEntity: The `UsergridEntity` which is connected.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func CONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        requestManager.performConnect(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    /**
    Disconnects the `UsergridEntity` objects via the relationship.
    - parameter entity: The `UsergridEntity` that contains the connection.
    - parameter relationship: The relationship of the two entities.
    - parameter connectingEntity: The `UsergridEntity` which is connected.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DISCONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        requestManager.performDisconnect(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }
}

// MARK: - Asset Management - 
extension UsergridClient {

    /**
    Uploads the asset and connects the data to the given `UsergridEntity`.
    - parameter entity: The `UsergridEntity` to connect the asset to.
    - parameter asset: The `UsergridAsset` to upload.
    - parameter progress: The progress block that will be called to update the progress of the upload.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func uploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        self.requestManager.performUploadAsset(entity, asset: asset, progress:progress) { [weak entity] (response, asset, error) -> Void in
            entity?.asset = asset
            completion?(response: response, asset: asset, error: error)
        }
    }

    /**
    Downloads the asset from the given `UsergridEntity`.
    - parameter entity: The `UsergridEntity` to which the asset to.
    - parameter contentType: The content type of the asset's data.
    - parameter progress: The optional progress block that will be called to update the progress of the download.
    - parameter completion: The optional completion block that will be called once the request has completed.
    */
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