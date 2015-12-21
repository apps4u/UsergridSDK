//
//  UsergridClient.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/3/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

/**
The `UsergridClient` class is the base handler for making client connections to and managing relationships with Usergrid's API.
*/
public class UsergridClient: NSObject {

    static let DEFAULT_BASE_URL = "https://api.usergrid.com"

    // MARK: - Instance Properties -

    lazy private var _requestManager: UsergridRequestManager = UsergridRequestManager(client: self)

    /// The application identifier.
    public let appID : String

    /// The organization identifier.
    public let orgID : String

    /// The base URL that all calls will be made with.
    public let baseURL : String

    /// The constructed URL string based on the `UsergridClient`'s `baseURL`, `orgID`, and `appID`.
    public var clientAppURL : String { return "\(baseURL)/\(orgID)/\(appID)" }

    /// The currently logged in `UsergridUser`.
    internal(set) public var currentUser: UsergridUser? = nil {
        didSet {
            if let newUser = self.currentUser {
                UsergridUser.saveCurrentUserKeychainItem(self,currentUser:newUser)
            } else if oldValue != nil {
                UsergridUser.deleteCurrentUserKeychainItem(self)
            }
        }
    }

    /// The `UsergridUserAuth` which consists of the token information from the `currentUser` property.
    public var userAuth: UsergridUserAuth? { return currentUser?.auth }

    /// The application level `UsergridAppAuth` object.  Can be set manually but must call `authenticateApp` to retrive token.
    public var appAuth: UsergridAppAuth? = nil

    /// The `UsergridAuthFallback` value used to determine what type of token will be sent, if any.
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
        self.internalInitialization()
    }

    /**
    Initializes instances of `UsergridClient`.

    - parameter orgID:      The organization identifier.
    - parameter appID:      The application identifier.
    - parameter baseURL:    The base URL that all calls will be made with.

    - returns: The new instance of `UsergridClient`.
    */
    public init(orgID: String, appID:String, baseURL:String) {
        self.orgID = orgID
        self.appID = appID
        self.baseURL = baseURL
        super.init()
        self.internalInitialization()
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
        super.init()
        self.internalInitialization()
    }

    private func internalInitialization() {
        self.currentUser = UsergridUser.getCurrentUserFromKeychain(self)
    }

    // MARK: - Device Registration/Push Notifications -

    /**
    Sets the push token for the given notifier ID and performs a PUT request to update the shared `UsergridDevice` instance.

    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The Usergrid notifier ID.
    - parameter completion: The completion block.
    */
    public func applyPushToken(pushToken: NSData, notifierID: String, completion: UsergridResponseCompletion? = nil) {
        self.applyPushToken(UsergridDevice.sharedDevice, pushToken: pushToken, notifierID: notifierID, completion: completion)
    }

    /**
    Sets the push token for the given notifier ID and performs a PUT request to update the given `UsergridDevice` instance.

    - parameter device:     The `UsergridDevice` object.
    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The Usergrid notifier ID.
    - parameter completion: The completion block.
    */
    public func applyPushToken(device: UsergridDevice, pushToken: NSData, notifierID: String, completion: UsergridResponseCompletion? = nil) {
        device.applyPushToken(pushToken, notifierID: notifierID)
        PUT(UsergridDevice.DEVICE_ENTITY_TYPE, jsonBody: device.jsonObjectValue, completion: completion)
    }

    // MARK: - Authorization -

    /**
    Determines the `UsergridAuth` object that will be used for all outgoing requests made.

    If there is a `UsergridUser` logged in and the token of that user is valid then it will return that.

    Otherwise, if the `authFallback` is `.App`, and the `UsergridAppAuth` of the client is set and the token is valid it will return that.

    - returns: The `UsergridAuth` if one is found or nil if not.
    */
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
    public func authenticateApp(completion: UsergridAppAuthCompletionBlock? = nil) {
        if let appAuth = self.appAuth {
            _requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
                self?.appAuth = auth
                completion?(auth: auth, error: error)
            }
        } else {
            completion?(auth: nil, error: "UsergridClient's appAuth is nil.")
        }
    }

    /**
    Authenticates with the `UsergridAppAuth` that is passed in.

    - parameter auth:       The `UsergridAppAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public func authenticateApp(appAuth: UsergridAppAuth, completion: UsergridAppAuthCompletionBlock? = nil) {
        _requestManager.performAuthRequest(appAuth:appAuth, request: appAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,error) in
            self?.appAuth = auth
            completion?(auth: auth, error: error)
        }
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in.

    - parameter auth:       The `UsergridUserAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public func authenticateUser(userAuth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock? = nil) {
        self.authenticateUser(userAuth, setAsCurrentUser:true, completion:completion)
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in.

    - parameter auth:               The `UsergridUserAuth` that will be authenticated.
    - parameter setAsCurrentUser:   If the authenticated user should be set as the `UsergridClient.currentUser`.
    - parameter completion:         The completion block that will be called after authentication has completed.
    */
    public func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser: Bool, completion: UsergridUserAuthCompletionBlock? = nil) {
        _requestManager.performAuthRequest(userAuth:userAuth, request: userAuth.buildAuthRequest(self.clientAppURL)) { [weak self] (auth,user,error) in
            if setAsCurrentUser {
                self?.currentUser = user
            }
            completion?(auth: auth, user: user, error: error)
        }
    }

    /**
    Logs out the current user locally and remotely.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public func logoutCurrentUser(completion:UsergridResponseCompletion? = nil) {
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

    /**
    Logs out the user remotely with the given tokens.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public func logoutUserAllTokens(uuidOrUsername:String, completion:UsergridResponseCompletion? = nil) {
        self.logoutUser(uuidOrUsername, token: nil, completion: completion)
    }

    /**
    Logs out a user with the give UUID or username using the shared instance of `UsergridCient`.

    Passing in a token will log out the user for just that token.  Passing in nil for the token will logout the user for all tokens.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public func logoutUser(uuidOrUsername:String, token:String?, completion:UsergridResponseCompletion? = nil) {
        _requestManager.performLogoutUserRequest(uuidOrUsername: uuidOrUsername, token:token, completion: completion)
    }

    // MARK: - GET -

    /**
    Gets a single `UsergridEntity` of a given type with a specific UUID/name.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performRequest(UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), method: .GET, completion: completion)
    }

    /**
    Gets a group of `UsergridEntity` objects of a given type with an optional query.

    - parameter type:       The `UsergridEntity` type.
    - parameter query:      The optional query to use when gathering `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performRequest(UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), method: .GET, completion: completion)
    }

    // MARK: - PUT -

    /**
    Updates an `UsergridEntity` with the given type and UUID/name specified using the passed in jsonBody.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter jsonBody:   The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion? = nil) {
        PUT(requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
    }

    /**
    Updates the passed in `UsergridEntity`.

    - parameter entity:     The `UsergridEntity` to update.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func PUT(entity: UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        PUT(entity.type, jsonBody: entity.jsonObjectValue, completion: completion)
    }

    /**
    Updates an `UsergridEntity` with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody.

    - Note: The `jsonBody` must contain a valid value for either `uuid` or `name` keys.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The optional completion block that will be called once the request has completed.
    */
    public func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion? = nil) {
        if let uuidOrName = jsonBody[UsergridEntityProperties.UUID.stringValue] as? String ?? jsonBody[UsergridEntityProperties.Name.stringValue] as? String {
            PUT(requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type,uuidOrName]), jsonBody: jsonBody, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "jsonBody not valid.", errorDescription: "The `jsonBody` must contain a valid value for either `uuid` or `name`."))
        }
    }

    /**
    Updates the entities that fit the given query using the passed in jsonBody.

    - Note: The query parameter must have a valid `collectionName` before calling this method.

    - parameter query:           The query to use when filtering what entities to update.
    - parameter jsonBody:        The valid JSON body dictionary to update with.
    - parameter queryCompletion: The completion block that will be called once the request has completed.
    */
    public func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletion? = nil) {
        if let type = query.collectionName {
            PUT(requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), jsonBody: jsonBody, completion: queryCompletion)
        } else {
            queryCompletion?(response: UsergridResponse(client:self, errorName: "Query collection name invalid.", errorDescription: "Query is missing a collection name."))
        }
    }

    private func PUT(requestURL requestURL: String, jsonBody: [String:AnyObject], completion: UsergridResponseCompletion? = nil) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            _requestManager.performRequest(requestURL,method: .PUT,headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER,body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion?(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }

    // MARK: - POST -

    /**
    Creates and posts creates an `UsergridEntity`.
    - parameter entity:     The `UsergridEntity` to create.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(entity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        POST(requestURL:UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [entity.type]), jsonBody: entity.jsonObjectValue, completion: completion)
    }

    /**
    Creates and posts an array of `UsergridEntity` objects.

    - Note: Each `UsergridEntity` in the array much already have a type assigned and must be the same.

    - parameter entities:           The `UsergridEntity` objects to create.
    - parameter entitiesCompletion: The completion block that will be called once the request has completed.
    */
    public func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletion? = nil) {
        if let entityType = entities.first?.type {
            POST(entityType, jsonBodies: entities.map { return ($0).jsonObjectValue }, completion: entitiesCompletion)
        } else {
            entitiesCompletion?(response: UsergridResponse(client:self, errorName: "No type found.", errorDescription: "The first entity in the array had no type found."))
        }
    }

    /**
    Creates and posts an `UsergridEntity` of the given type with the given jsonBody.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion? = nil) {
        POST(requestURL:UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBody, completion: completion)
    }

    /**
    Creates and posts an array of `Entity` objects while assigning the given type to them.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionaries to use when creating the `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletion? = nil) {
        POST(requestURL:UsergridRequestManager.buildRequestURL(self.clientAppURL,paths: [type]), jsonBody: jsonBodies, completion:completion)
    }

    /**
    Creates and posts an `UsergridEntity` of the given type with a given name and the given jsonBody.

    - parameter type:       The `UsergridEntity` type.
    - parameter name:       The name of the `UsergridEntity`.
    - parameter jsonBody:   The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion? = nil) {
        var jsonBodyWithName = jsonBody
        jsonBodyWithName[UsergridEntityProperties.Name.stringValue] = name
        POST(type, jsonBody: jsonBodyWithName,completion: completion)
    }

    private func POST(requestURL requestURL: String, jsonBody: AnyObject, completion: UsergridResponseCompletion? = nil) {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions.PrettyPrinted)
            _requestManager.performRequest(requestURL, method: .POST, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, body: jsonData,completion: completion)
        } catch let caught as NSError {
            print(caught)
            completion?(response: UsergridResponse(client:self, errorName: caught.domain, errorDescription: caught.localizedDescription))
        }
    }

    // MARK: - DELETE -

    /**
    Destroys the passed `UsergridEntity`.

    - Note: The entity object must have a `uuid` or `name` assigned.

    - parameter entity:     The `UsergridEntity` to delete.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        if let uuidOrName = entity.uuid ?? entity.name?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) {
            DELETE(entity.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion?(response: UsergridResponse(client:self, errorName: "No UUID or name found.", errorDescription: "The entity object must have a `uuid` or `name` assigned."))
        }
    }

    /**
    Destroys the `UsergridEntity` objects that fit the given `UsergridQuery`.

    - Note: The query parameter must have a valid `collectionName` before calling this method.

    - parameter query:              The query to use when filtering what entities to delete.
    - parameter queryCompletion:    The completion block that will be called once the request has completed.
    */
    public func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletion? = nil) {
        if let type = query.collectionName {
            DELETE(requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL,query: query, paths: [type]), completion: queryCompletion)
        } else {
            queryCompletion?(response: UsergridResponse(client:self, errorName: "Query collection name invalid.", errorDescription: "Query is missing a collection name."))
        }
    }

    /**
    Destroys the `UsergridEntity` of a given type with a specific UUID/name.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletion? = nil) {
        DELETE(requestURL: UsergridRequestManager.buildRequestURL(self.clientAppURL, paths: [type,uuidOrName]), completion: completion)
    }

    private func DELETE(requestURL requestURL:String, completion:UsergridResponseCompletion? = nil) {
        _requestManager.performRequest(requestURL, method: .DELETE, headers:UsergridRequestManager.JSON_CONTENT_TYPE_HEADER, completion: completion)
    }

    // MARK: - Connection Management -

    /**
    Connects the `UsergridEntity` objects via the relationship.

    - parameter entity:             The `UsergridEntity` that will contain the connection.
    - parameter relationship:       The relationship of the connection.
    - parameter to:                 The `UsergridEntity` which is connected.
    - parameter completion:         The completion block that will be called once the request has completed.
    */
    public func connect(entity:UsergridEntity, relationship:String, to:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performConnect(entity, relationship: relationship, to: to, completion: completion)
    }

    /**
     Connects the entity objects via the relationship.

     - parameter entityType:       The entity type.
     - parameter entityID:         The entity UUID or name.
     - parameter relationship:     The relationship of the connection.
     - parameter toType:           The optional type of the entity you are connecting to.
     - parameter toID:             The UUID of the entity you are connecting to.
     - parameter completion:       The completion block that will be called once the request has completed.
     */
    public func connect(entityType:String, entityID:String, relationship:String, toType:String?, toID: String, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performConnect(entityType, entityID: entityID, relationship: relationship, toType: toType, toID: toID, completion: completion)
    }

    /**
     Connects the entity objects via the relationship.

     - parameter entityType:       The entity type.
     - parameter entityID:         The entity UUID or name.
     - parameter relationship:     The relationship of the connection.
     - parameter toType:           The type of the entity you are connecting to.
     - parameter toName:           The name of the entity you are connecting to.
     - parameter completion:       The completion block that will be called once the request has completed.
     */
    public func connect(entityType:String, entityID:String, relationship:String, toType:String, toName: String, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performConnect(entityType, entityID: entityID, relationship: relationship, toType: toType, toName: toName, completion: completion)
    }

    /**
    Disconnects the `UsergridEntity` objects via the relationship.

    - parameter entity:             The `UsergridEntity` that contains the connection.
    - parameter relationship:       The relationship of the connection.
    - parameter from:               The `UsergridEntity` which is connected.
    - parameter completion:         The completion block that will be called once the request has completed.
    */
    public func disconnect(entity:UsergridEntity, relationship:String, from:UsergridEntity, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performDisconnect(entity, relationship: relationship, from: from, completion: completion)
    }

    /**
     Disconnects the entity objects via the relationship.

     - parameter entityType:       The entity type.
     - parameter entityID:         The entity UUID or name.
     - parameter relationship:     The relationship of the connection.
     - parameter fromType:         The optional type of the entity you are disconnecting from.
     - parameter toID:             The UUID of the entity you are disconnecting from.
     - parameter completion:       The completion block that will be called once the request has completed.
     */
    public func disconnect(entityType:String, entityID:String, relationship:String, fromType:String?, fromID: String, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performDisconnect(entityType, entityID: entityID, relationship: relationship, fromType: fromType, fromID: fromID, completion: completion)
    }

    /**
     Disconnects the entity objects via the relationship.

     - parameter entityType:       The entity type.
     - parameter entityID:         The entity UUID or name.
     - parameter relationship:     The relationship of the connection.
     - parameter fromType:         The type of the entity you are disconnecting from.
     - parameter fromName:         The name of the entity you are disconnecting from.
     - parameter completion:       The completion block that will be called once the request has completed.
     */
    public func disconnect(entityType:String, entityID:String, relationship:String, fromType:String, fromName: String, completion: UsergridResponseCompletion? = nil) {
        _requestManager.performDisconnect(entityType, entityID: entityID, relationship: relationship, fromType: fromType, fromName: fromName, completion: completion)
    }

    /**
    Gets the connected entities for the given relationship.

    - parameter entity:       The entity that contains the connection.
    - parameter relationship: The relationship of the connection.
    - parameter completion:   The completion block that will be called once the request has completed.
    */
    public func getConnections(direction:UsergridDirection, entity:UsergridEntity, relationship:String, completion:UsergridResponseCompletion? = nil) {
        _requestManager.getConnections(direction, entity: entity, relationship: relationship, completion: completion)
    }

    /**
     Gets the connected entities for the given relationship.

     - parameter direction:        The direction of the connection.
     - parameter entityType:       The entity type.
     - parameter entityID:         The entity UUID or name.
     - parameter relationship:     The relationship of the connection.
     - parameter completion:       The completion block that will be called once the request has completed.
     */
    public func getConnections(direction:UsergridDirection, entityType:String, entityID:String, relationship:String, completion:UsergridResponseCompletion? = nil) {
        _requestManager.getConnections(direction, entityType: entityType, entityID: entityID, relationship: relationship, completion: completion)
    }

    // MARK: - Asset Management -

    /**
    Uploads the asset and connects the data to the given `UsergridEntity`.

    - parameter entity:     The `UsergridEntity` to connect the asset to.
    - parameter asset:      The `UsergridAsset` to upload.
    - parameter progress:   The progress block that will be called to update the progress of the upload.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public func uploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion? = nil) {
        _requestManager.performUploadAsset(entity, asset: asset, progress:progress) { [weak entity] (response, asset, error) -> Void in
            entity?.asset = asset
            completion?(response: response, asset: asset, error: error)
        }
    }

    /**
    Downloads the asset from the given `UsergridEntity`.

    - parameter entity:         The `UsergridEntity` to which the asset to.
    - parameter contentType:    The content type of the asset's data.
    - parameter progress:       The optional progress block that will be called to update the progress of the download.
    - parameter completion:     The optional completion block that will be called once the request has completed.
    */
    public func downloadAsset(entity:UsergridEntity, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion? = nil) {
        if entity.hasAsset {
            _requestManager.performGetAsset(entity, contentType: contentType, progress:progress) { (asset, error) -> Void in
                completion?(asset: asset, error: error)
            }
        } else {
            completion?(asset: nil, error: "Entity does not have an asset attached.")
        }
    }
}
