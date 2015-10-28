//
//  Usergrid.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

/**
The `Usergrid` class acts as a static shared instance manager for the `UsergridClient` class.

The methods and variables in this class are all static and therefore you will never need or want to initialize an instance of the `Usergrid` class.

Use of this class depends on initialization of the shared instance of the `UsergridClient` object.  Because of this, before using any of the static methods
provided you will need to call one of the shared instance initialization methods.  Failure to do so will result in failure from all methods.
*/
public class Usergrid: NSObject {

    // MARK: - Static Variables -

    internal static var _sharedClient : UsergridClient!

    /// Used to determine if the shared instance of the `UsergridClient` has been initialized.
    public static var isInitialized : Bool  { return Usergrid._sharedClient != nil }

    /**
    A shared instance of `UsergridClient`, used by the `Usergrid` static methods and acts as the default `UsergridClient`
    within the UsergridSDK library.

    - Warning: You must call one of the `Usergrid.initSharedInstance` methods before this or any other `Usergrid` static methods are valid.
    */
    public static var sharedInstance : UsergridClient {
        assert(Usergrid.isInitialized, "Usergrid shared instance is not initalized!")
        return Usergrid._sharedClient
    }

    /// The application identifier the shared instance of `UsergridClient`.
    public static var appID : String { return Usergrid.sharedInstance.appID }

    /// The organization identifier of the shared instance of `UsergridClient`.
    public static var orgID : String { return Usergrid.sharedInstance.orgID }

    /// The base URL that all calls will be made with of the shared instance of `UsergridClient`.
    public static var baseURL : String { return Usergrid.sharedInstance.baseURL }

    /// The constructed URL string based on the `UsergridClient`'s baseURL, orgID, and appID of the shared instance of `UsergridClient`.
    public static var clientAppURL : String { return Usergrid.sharedInstance.clientAppURL }

    /// The currently logged in `UsergridUser` of the shared instance of `UsergridClient`.
    public static var currentUser: UsergridUser?  { return Usergrid.sharedInstance.currentUser }

    /// The `UsergridUserAuth` which consists of the token information from the `currentUser` property of the shared instance of `UsergridClient`.
    public static var userAuth: UsergridUserAuth?  { return Usergrid.sharedInstance.userAuth }

    /// The application level `UsergridAppAuth` object of the shared instance of `UsergridClient`.
    public static var appAuth: UsergridAppAuth?  {
        get{ return Usergrid.sharedInstance.appAuth }
        set{ Usergrid.sharedInstance.appAuth = appAuth }
    }

    // MARK: - Initialization -

    /**
    Initializes the `Usergrid.sharedInstance` of `UsergridClient`.

    - parameter orgID: The organization identifier.
    - parameter appID: The application identifier.

    - returns: The shared instance of `UsergridClient`.
    */
    public static func initSharedInstance(orgID orgID : String, appID: String) -> UsergridClient {
        if !Usergrid.isInitialized {
            Usergrid._sharedClient = UsergridClient(orgID: orgID, appID: appID)
        } else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    /**
    Initializes the `Usergrid.sharedInstance` of `UsergridClient`.

    - parameter orgID:      The organization identifier.
    - parameter appID:      The application identifier.
    - parameter baseURL:    The base URL that all calls will be made with.

    - returns: The shared instance of `UsergridClient`.
    */
    public static func initSharedInstance(orgID orgID : String, appID: String, baseURL: String) -> UsergridClient {
        if !Usergrid.isInitialized {
            Usergrid._sharedClient = UsergridClient(orgID: orgID, appID: appID, baseURL: baseURL)
        } else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    /**
    Initializes the `Usergrid.sharedInstance` of `UsergridClient`.

    - parameter configuration: The configuration for the client to be set up with.
    
    - returns: The shared instance of `UsergridClient`.
    */
    public static func initSharedInstance(configuration configuration: UsergridClientConfig) -> UsergridClient {
        if !Usergrid.isInitialized {
            Usergrid._sharedClient = UsergridClient(configuration: configuration)
        }  else {
            print("The Usergrid shared instance was already initialized. All subsequent initialization attempts (including this) will be ignored.")
        }
        return Usergrid._sharedClient
    }

    // MARK: - Push Notifications -

    /**
    Sets the push token for the given notifier ID and performs a PUT request to update the shared `UsergridDevice` instance using the shared instance of `UsergridCient`.

    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The Usergrid notifier ID.
    - parameter completion: The completion block.
    */
    public static func applyPushToken(pushToken: NSData, notifierID: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.applyPushToken(pushToken, notifierID: notifierID, completion: completion)
    }

    /**
    Sets the push token for the given notifier ID and performs a PUT request to update the given `UsergridDevice` instance using the shared instance of `UsergridCient`.

    - parameter device:     The `UsergridDevice` object.
    - parameter pushToken:  The push token from Apple.
    - parameter notifierID: The Usergrid notifier ID.
    - parameter completion: The completion block.
    */
    public static func applyPushToken(device: UsergridDevice, pushToken: NSData, notifierID: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.applyPushToken(device, pushToken: pushToken, notifierID: notifierID, completion: completion)
    }


    // MARK: - Authorization -

    /// The `UsergridAuthFallback` value used to determine what type of token will be sent of the shared instance of `UsergridClient`, if any.
    public static var authFallback: UsergridAuthFallback {
        get{ return Usergrid.sharedInstance.authFallback }
        set { Usergrid.sharedInstance.authFallback = authFallback }
    }

    /**
    Determines the `UsergridAuth` object that will be used for all outgoing requests made by the shared instance of `UsergridClient`.

    If there is a `UsergridUser` logged in and the token of that user is valid then it will return that.

    Otherwise, if the `authFallback` is `.App`, and the `UsergridAppAuth` of the client is set and the token is valid it will return that.

    - returns: The `UsergridAuth` if one is found or nil if not.
    */
    public static func authForRequests() -> UsergridAuth? {
        return Usergrid.sharedInstance.authForRequests()
    }

    /**
    Authenticates with the `UsergridAppAuth` that is contained within the shared instance of `UsergridCient`.

    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public static func authenticateApp(completion: UsergridAppAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateApp(completion)
    }

    /**
    Authenticates with the `UsergridAppAuth` that is passed in using the shared instance of `UsergridCient`.

    - parameter auth:       The `UsergridAppAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public static func authenticateApp(auth: UsergridAppAuth, completion: UsergridAppAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateApp(auth, completion: completion)
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in using the shared instance of `UsergridCient`.

    - parameter auth:       The `UsergridUserAuth` that will be authenticated.
    - parameter completion: The completion block that will be called after authentication has completed.
    */
    public static func authenticateUser(auth: UsergridUserAuth, completion: UsergridUserAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateUser(auth, completion: completion)
    }

    /**
    Authenticates with the `UsergridUserAuth` that is passed in using the shared instance of `UsergridCient`.

    - parameter auth:               The `UsergridUserAuth` that will be authenticated.
    - parameter setAsCurrentUser:   If the authenticated user should be set as the `UsergridClient.currentUser`.
    - parameter completion:         The completion block that will be called after authentication has completed.
    */
    public static func authenticateUser(userAuth: UsergridUserAuth, setAsCurrentUser:Bool, completion: UsergridUserAuthCompletionBlock?) {
        Usergrid.sharedInstance.authenticateUser(userAuth, setAsCurrentUser: setAsCurrentUser, completion: completion)
    }

    /**
    Logs out the current user of the shared instance locally and remotely.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public static func logoutCurrentUser(completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.logoutCurrentUser(completion)
    }

    /**
    Logs out the user remotely with the given tokens using the shared instance of `UsergridCient`.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public static func logoutUserAllTokens(uuidOrUsername:String, completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.logoutUserAllTokens(uuidOrUsername, completion: completion)
    }

    /**
    Logs out a user with the give UUID or username using the shared instance of `UsergridCient`.
    
    Passing in a token will log out the user for just that token.  Passing in nil for the token will logout the user for all tokens.

    - parameter completion: The completion block that will be called after logout has completed.
    */
    public static func logoutUser(uuidOrUsername:String, token:String?, completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.logoutUser(uuidOrUsername, token: token, completion: completion)
    }

    // MARK: - GET -

    /**
    Gets a single `UsergridEntity` of a given type with a specific UUID/name using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func GET(type: String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.GET(type,uuidOrName:uuidOrName,completion:completion)
    }

    /**
    Gets a group of `UsergridEntity` objects of a given type with an optional query using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter query:      The optional query to use when gathering `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func GET(type: String, query: UsergridQuery? = nil, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.GET(type,query:query,completion:completion)
    }

    // MARK: - PUT -

    /**
    Updates an `UsergridEntity` with the given type and UUID/name specified using the passed in jsonBody using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter jsonBody:   The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func PUT(type: String, uuidOrName: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(type, uuidOrName: uuidOrName, jsonBody: jsonBody, completion: completion)
    }

    /**
    Updates an `UsergridEntity` with the given type using the jsonBody where the UUID/name is specified inside of the jsonBody using the shared instance of `UsergridCient`.

    - Note: The `jsonBody` must contain a valid value for either `uuid` or `name`.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionary to update the `UsergridEntity` with.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func PUT(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(type, jsonBody: jsonBody, completion: completion)
    }

    /**
    Updates the passed in `UsergridEntity` using the shared instance of `UsergridCient`.

    - parameter entity:     The `UsergridEntity` to update.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func PUT(entity: UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(entity, completion: completion)
    }

    /**
    Updates the entities that fit the given query using the passed in jsonBody using the shared instance of `UsergridCient`.

    - Note: The query parameter must have a valid `collectionName` before calling this method.

    - parameter query:              The query to use when filtering what entities to update.
    - parameter jsonBody:           The valid JSON body dictionary to update with.
    - parameter queryCompletion:    The completion block that will be called once the request has completed.
    */
    public static func PUT(query: UsergridQuery, jsonBody:[String:AnyObject], queryCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.PUT(query, jsonBody: jsonBody, queryCompletion: queryCompletion)
    }

    // MARK: - POST -

    /**
    Creates and posts an `UsergridEntity` of the given type with a given name and the given jsonBody using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter name:       The name of the `UsergridEntity`.
    - parameter jsonBody:   The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func POST(type: String, name: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, name: name, jsonBody: jsonBody, completion: completion)
    }

    /**
    Creates and posts an `UsergridEntity` of the given type with the given jsonBody using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionary to use when creating the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func POST(type: String, jsonBody:[String:AnyObject], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, jsonBody: jsonBody, completion: completion)
    }

    /**
    Creates and posts an array of `Entity` objects while assinging the given type to them using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter jsonBody:   The valid JSON body dictionaries to use when creating the `UsergridEntity` objects.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func POST(type: String, jsonBodies:[[String:AnyObject]], completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(type, jsonBodies: jsonBodies, completion: completion)
    }

    /**
    Creates and posts creates an `UsergridEntity` using the shared instance of `UsergridCient`.

    - parameter entity:     The `UsergridEntity` to create.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func POST(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(entity, completion: completion)
    }

    /**
    Creates and posts an array of `UsergridEntity` objects using the shared instance of `UsergridCient`.
    
    - Note: Each `UsergridEntity` in the array much already have a type assigned and must be the same.

    - parameter entities:           The `UsergridEntity` objects to create.
    - parameter entitiesCompletion: The completion block that will be called once the request has completed.
    */
    public static func POST(entities:[UsergridEntity], entitiesCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.POST(entities, entitiesCompletion: entitiesCompletion)
    }

    // MARK: - DELETE -

    /**
    Destroys the `UsergridEntity` of a given type with a specific UUID/name using the shared instance of `UsergridCient`.

    - parameter type:       The `UsergridEntity` type.
    - parameter uuidOrName: The UUID or name of the `UsergridEntity`.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func DELETE(type:String, uuidOrName: String, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(type, uuidOrName: uuidOrName, completion: completion)
    }

    /**
    Destroys the passed `UsergridEntity` using the shared instance of `UsergridCient`.

    - Note: The entity object must have a `uuid` or `name` assigned.

    - parameter entity:     The `UsergridEntity` to delete.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func DELETE(entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(entity, completion:completion)
    }

    /**
    Destroys the `UsergridEntity` objects that fit the given `UsergridQuery` using the shared instance of `UsergridCient`.

    - Note: The query parameter must have a valid `collectionName` before calling this method.

    - parameter query:              The query to use when filtering what entities to delete.
    - parameter queryCompletion:    The completion block that will be called once the request has completed.
    */
    public static func DELETE(query:UsergridQuery, queryCompletion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(query, queryCompletion:queryCompletion)
    }

    // MARK: - Connection Management -

    /**
    Connects the `UsergridEntity` objects via the relationship using the shared instance of `UsergridCient`.

    - parameter entity:             The entity that will contain the connection.
    - parameter relationship:       The relationship of the two entities.
    - parameter connectingEntity:   The entity which is connected.
    - parameter completion:         The completion block that will be called once the request has completed.
    */
    public static func CONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.CONNECT(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    /**
    Disconnects the `UsergridEntity` objects via the relationship using the shared instance of `UsergridCient`.

    - parameter entity:             The entity that contains the connection.
    - parameter relationship:       The relationship of the two entities.
    - parameter connectingEntity:   The entity which is connected.
    - parameter completion:         The completion block that will be called once the request has completed.
    */
    public static func DISCONNECT(entity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DISCONNECT(entity, relationship: relationship, connectingEntity: connectingEntity, completion: completion)
    }

    /**
    Gets the connected entities for the given relationship using the shared instance of `UsergridCient`.

    - parameter entity:       The entity that contains the connection.
    - parameter relationship: The relationship.
    - parameter completion:   The completion block that will be called once the request has completed.
    */
    public static func getConnectedEntities(entity:UsergridEntity, relationship:String, completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.getConnectedEntities(entity, relationship: relationship, completion: completion)
    }

    // MARK: - Asset Management -

    /**
    Uploads the asset and connects the data to the given `UsergridEntity` using the shared instance of `UsergridCient`.

    - parameter entity:     The entity to connect the asset to.
    - parameter asset:      The asset to upload.
    - parameter progress:   The progress block that will be called to update the progress of the upload.
    - parameter completion: The completion block that will be called once the request has completed.
    */
    public static func uploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        Usergrid.sharedInstance.uploadAsset(entity, asset: asset, progress: progress, completion: completion)
    }

    /**
    Downloads the asset from the given `UsergridEntity` using the shared instance of `UsergridCient`.

    - parameter entity:         The entity to which the asset to.
    - parameter contentType:    The content type of the asset's data.
    - parameter progress:       The progress block that will be called to update the progress of the download.
    - parameter completion:     The completion block that will be called once the request has completed.
    */
    public static func downloadAsset(entity:UsergridEntity, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        Usergrid.sharedInstance.downloadAsset(entity, contentType: contentType, progress: progress, completion: completion)
    }
}
