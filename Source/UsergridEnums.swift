//
//  UsergridEnums.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/21/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

let ENTITY_TYPE = "type"
let ENTITY_UUID = "uuid"
let ENTITY_NAME = "name"
let ENTITY_CREATED = "created"
let ENTITY_MODIFIED = "modified"
let ENTITY_LOCATION = "location"
let ENTITY_LATITUDE = "latitude"
let ENTITY_LONGITUDE = "longitude"

let USER_USERNAME = "username"
let USER_PASSWORD = "password"
let USER_EMAIL = "email"
let USER_AGE = "age"
let USER_ACTIVATED = "activated"
let USER_DISABLED = "disabled"
let USER_PICTURE = "picture"

/**
A enumeration that is used to determine what the `UsergridClient` will fallback to depending on certain authorization conditions.
*/
@objc public enum UsergridAuthFallback : Int {

    // MARK: - Values -

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
`UsergridEntity` specific properties keys.  Note that trying to mutate the values of these properties will not be allowed in most cases.
*/
@objc public enum UsergridEntityProperties : Int {

    // MARK: - Values -

    case EntityType
    case UUID
    case Name
    case Created
    case Modified
    case Location

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridEntityProperties` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridEntityProperties` or nil.
    */
    public static func fromString(stringValue: String) -> UsergridEntityProperties? {
        switch stringValue.lowercaseString {
            case ENTITY_TYPE: return .EntityType
            case ENTITY_UUID: return .UUID
            case ENTITY_NAME: return .Name
            case ENTITY_CREATED: return .Created
            case ENTITY_MODIFIED: return .Modified
            case ENTITY_LOCATION: return .Location
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .EntityType: return ENTITY_TYPE
            case .UUID: return ENTITY_UUID
            case .Name: return ENTITY_NAME
            case .Created: return ENTITY_CREATED
            case .Modified: return ENTITY_MODIFIED
            case .Location: return ENTITY_LOCATION
        }
    }

    /**
    Determines if the `UsergridEntityProperties` is mutable for the given entity.

    - parameter entity: The entity to check.

    - returns: If the `UsergridEntityProperties` is mutable for the given entity
    */
    public func isMutableForEntity(entity:UsergridEntity) -> Bool {
        switch self {
            case .EntityType,.UUID,.Created,.Modified: return false
            case .Location: return true
            case .Name: return entity.isUser
        }
    }
}

@objc public enum UsergridUserProperties: Int {

    // MARK: - Values -

    case Name
    case Username
    case Password
    case Email
    case Age
    case Activated
    case Disabled
    case Picture

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridUserProperties` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridUserProperties` or nil.
    */
    public static func fromString(stringValue: String) -> UsergridUserProperties? {
        switch stringValue.lowercaseString {
            case ENTITY_NAME: return .Name
            case USER_USERNAME: return .Username
            case USER_PASSWORD: return .Password
            case USER_EMAIL: return .Email
            case USER_AGE: return .Age
            case USER_ACTIVATED: return .Activated
            case USER_DISABLED: return .Disabled
            case USER_PICTURE: return .Picture
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .Name: return ENTITY_NAME
            case .Username: return USER_USERNAME
            case .Password: return USER_PASSWORD
            case .Email: return USER_EMAIL
            case .Age: return USER_AGE
            case .Activated: return USER_ACTIVATED
            case .Disabled: return USER_DISABLED
            case .Picture: return USER_PICTURE
        }
    }
}

/**
`UsergridQuery` specific operators.
*/
@objc public enum UsergridQueryOperator: Int {

    // MARK: - Values -

    case Equal
    case GreaterThan
    case GreaterThanEqualTo
    case LessThan
    case LessThanEqualTo

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridQueryOperator` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridQueryOperator` or nil.
    */
    public static func fromString(stringValue: String) -> UsergridQueryOperator? {
        switch stringValue.lowercaseString {
            case UsergridQuery.EQUAL: return .Equal
            case UsergridQuery.GREATER_THAN: return .GreaterThan
            case UsergridQuery.GREATER_THAN_EQUAL_TO: return .GreaterThanEqualTo
            case UsergridQuery.LESS_THAN: return .LessThan
            case UsergridQuery.LESS_THAN_EQUAL_TO: return .LessThanEqualTo
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .Equal: return UsergridQuery.EQUAL
            case .GreaterThan: return UsergridQuery.GREATER_THAN
            case .GreaterThanEqualTo: return UsergridQuery.GREATER_THAN_EQUAL_TO
            case .LessThan: return UsergridQuery.LESS_THAN
            case .LessThanEqualTo: return UsergridQuery.LESS_THAN_EQUAL_TO
        }
    }
}

/**
`UsergridQuery` specific sort orders.
*/
@objc public enum UsergridQuerySortOrder: Int {

    // MARK: - Values -

    case Asc
    case Desc

    // MARK: - Methods -

    /**
    Gets the corresponding `UsergridQuerySortOrder` from a string if it's valid.

    - parameter stringValue: The string value to convert.

    - returns: The corresponding `UsergridQuerySortOrder` or nil.
    */
    public static func fromString(stringValue: String) -> UsergridQuerySortOrder? {
        switch stringValue.lowercaseString {
            case UsergridQuery.ASC: return .Asc
            case UsergridQuery.DESC: return .Desc
            default: return nil
        }
    }

    /// Returns the string value.
    public var stringValue: String {
        switch self {
            case .Asc: return UsergridQuery.ASC
            case .Desc: return UsergridQuery.DESC
        }
    }
}

/**
`UsergridAsset` image specific content types.
*/
@objc public enum UsergridImageContentType : Int {

    // MARK: - Values -

    case Png
    case Jpeg

    // MARK: - Methods -

    /// Returns the string value.
    public var stringValue: String {
        switch self {
        case .Png: return "image/png"
        case .Jpeg: return "image/jpeg"
        }
    }
}