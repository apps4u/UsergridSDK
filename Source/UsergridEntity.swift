//
//  UsergridEntity.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation
import CoreLocation

/**
`UsergridEntity` is the base class that contains a single Usergrid entity. 

`UsergridEntity` maintains a set of accessor properties for standard Usergrid schema properties (e.g. name, uuid), and supports helper methods for accessing any custom properties that might exist.
*/
public class UsergridEntity: NSObject {

    // MARK: - Instance Properties -

    /// The property dictionary that stores the properties values of the `UsergridEntity` object.
    var properties: [String : AnyObject] {
        didSet {
            if let fileMetaData = properties.removeValueForKey(UsergridFileMetaData.FILE_METADATA) as? [String:AnyObject] {
                self.fileMetaData = UsergridFileMetaData(fileMetaDataJSON: fileMetaData)
            } else {
                self.fileMetaData = nil
            }
        }
    }

    /// The `UsergridAsset` that contains the asset data.
    public var asset: UsergridAsset?

    /// The `UsergridFileMetaData` of this `UsergridEntity`.
    private(set) public var fileMetaData : UsergridFileMetaData?

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.EntityType`.
    public var type: String { return self.getEntitySpecificProperty(.EntityType) as! String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.UUID`.
    public var uuid: String? { return self.getEntitySpecificProperty(.UUID) as? String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.Name`.
    public var name: String? { return self.getEntitySpecificProperty(.Name) as? String }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.Created`.
    public var created: NSDate? { return self.getEntitySpecificProperty(.Created) as? NSDate }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.Modified`.
    public var modified: NSDate? { return self.getEntitySpecificProperty(.Modified) as? NSDate }

    /// Property helper method for the `UsergridEntity` objects `UsergridEntityProperties.Location`.
    public var location: CLLocation? {
        get { return self.getEntitySpecificProperty(.Location) as? CLLocation }
        set { self[UsergridEntityProperties.Location.stringValue] = newValue }
    }

    /// Property helper method to get the UUID or name of the `UsergridEntity`.
    public var uuidOrName: String? { return self.uuid ?? self.name }

    /// Tells you if this `UsergridEntity` has a type of `user`.
    public var isUser: Bool { return self is UsergridUser || self.type == UsergridUser.USER_ENTITY_TYPE }

    /// Tells you if there is an asset associated with this entity.
    public var hasAsset: Bool { return self.asset != nil || self.fileMetaData?.contentLength > 0 }

    /// The JSON object value.
    public var jsonObjectValue : [String:AnyObject] { return self.properties }

    /// The string value.
    public var stringValue : String { return NSString(data: try! NSJSONSerialization.dataWithJSONObject(self.jsonObjectValue, options: NSJSONWritingOptions.PrettyPrinted), encoding: NSASCIIStringEncoding) as! String }
    
    // MARK: - Initialization -

    /*!
    Designated initializer for `UsergridEntity` objects

    - parameter type:         The type associated with the `UsergridEntity` object.
    - parameter name:         The optional name associated with the `UsergridEntity` object.
    - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

    - returns: A new `UsergridEntity` object.
    */
    public init(type:String, name:String? = nil, propertyDict:[String:AnyObject]? = nil) {
        self.properties = propertyDict ?? [:]
        super.init()
        if self is UsergridUser {
            self.properties[UsergridEntityProperties.EntityType.stringValue] = UsergridUser.USER_ENTITY_TYPE
        } else {
            self.properties[UsergridEntityProperties.EntityType.stringValue] = type
        }
        if let entityName = name {
            self.properties[UsergridEntityProperties.Name.stringValue] = entityName
        }
    }

    /*!
    Class convenience constructor for creating `UsergridEntity` objects dynamically.

    - parameter jsonDict: A valid JSON dictionary which must contain at the very least a value for the `type` key.

    - returns: A `UsergridEntity` object provided that the `type` key within the dictionay exists. Otherwise nil.
    */
    public class func entity(jsonDict jsonDict: [String:AnyObject]) -> UsergridEntity? {
        if let type = jsonDict[UsergridEntityProperties.EntityType.stringValue] as? String {
            if UsergridUser.USER_ENTITY_TYPE == type {
                let user = UsergridUser()
                user.properties = jsonDict
                return user
            } else {
                return UsergridEntity(type:type, propertyDict:jsonDict)
            }
        } else {
            return nil
        }
    }

    /**
    Class convenience constructor for creating multiple `UsergridEntity` objects dynamically.

    - parameter entitiesJSONArray: An array which contains dictionaries that are used to create the `UsergridEntity` objects.

    - returns: An array of `UsergridEntity`.
    */
    public class func entities(jsonArray entitiesJSONArray: [[String:AnyObject]]) -> [UsergridEntity] {
        var entityArray : [UsergridEntity] = []
        for entityJSONDict in entitiesJSONArray {
            if let entity = UsergridEntity.entity(jsonDict:entityJSONDict) {
                entityArray.append(entity)
            }
        }
        return entityArray
    }

    // MARK: - Property Manipulation -

    public subscript(propertyName: String) -> AnyObject? {
        get {
            if let entityProperty = UsergridEntityProperties.fromString(propertyName) {
                return self.getEntitySpecificProperty(entityProperty)
            } else {
                let propertyValue = self.properties[propertyName]
                if propertyValue === NSNull() { // Let's just return nil for properties that have been removed instead of NSNull
                    return nil
                } else {
                    return propertyValue
                }
            }
        }
        set(propertyValue) {
            if let value = propertyValue {
                if let entityProperty = UsergridEntityProperties.fromString(propertyName) {
                    if entityProperty.isMutableForEntity(self) {
                        if entityProperty == .Location {
                            if let location = value as? CLLocation {
                                properties[propertyName] = [ENTITY_LATITUDE:location.coordinate.latitude,
                                                            ENTITY_LONGITUDE:location.coordinate.longitude]
                            } else if let location = value as? CLLocationCoordinate2D {
                                properties[propertyName] = [ENTITY_LATITUDE:location.latitude,
                                                            ENTITY_LONGITUDE:location.longitude]
                            } else if let location = value as? [String:Double] {
                                if let lat = location[ENTITY_LATITUDE], long = location[ENTITY_LONGITUDE] {
                                    properties[propertyName] = [ENTITY_LATITUDE:lat,
                                                                ENTITY_LONGITUDE:long]
                                }
                            }
                        } else {
                            properties[propertyName] = value
                        }
                    }
                } else {
                    properties[propertyName] = value
                }
            } else { // If the property value is nil we assume they wanted to remove the property.

                // We set the value for this property to Null so that when a PUT is performed on the entity the property will actually be removed from the Entity on Usergrid
                if let entityProperty = UsergridEntityProperties.fromString(propertyName){
                    if entityProperty.isMutableForEntity(self) {
                        properties[propertyName] = NSNull()
                    }
                } else {
                    properties[propertyName] = NSNull()
                }
            }
        }
    }

    /**
    Updates a properties value for the given property name.

    - parameter name:  The name of the property.
    - parameter value: The value to update to.
    */
    public func putProperty(name:String,value:AnyObject?) {
        self[name] = value
    }

    /**
    Updates a set of properties that are within the given properties dictionary.

    - parameter properties: The property dictionary containing the properties names and values.
    */
    public func putProperties(properties:[String:AnyObject]) {
        for (name,value) in properties {
            self.putProperty(name, value: value)
        }
    }

    /**
    Removes the property for the given property name.

    - parameter name: The name of the property.
    */
    public func removeProperty(name:String) {
        self[name] = nil
    }

    /**
    Removes the properties with the names within the propertyNames array

    - parameter propertyNames: An array of property names.
    */
    public func removeProperties(propertyNames:[String]) {
        for name in propertyNames {
            self.removeProperty(name)
        }
    }

    /**
    Appends the given value to the end of the properties current value.

    - parameter name:  The name of the property.
    - parameter value: The value to append.
    */
    public func push(name:String,value:AnyObject) {
        self.insertArray(name, index: Int.max, values:[value])
    }

    /**
    Appends the given values to the end of the properties current value.

    - parameter name:  The name of the property.
    - parameter values: The values to append.
    */
    public func append(name:String,values:[AnyObject]) {
        self.insertArray(name, index: Int.max, values: values)
    }

    /**
    Inserts the given value at the given index within the properties current value.

    - parameter name:  The name of the property.
    - parameter index: The index to insert at.
    - parameter value: The value to insert.
    */
    public func insert(name:String,index:Int = 0,value:AnyObject) {
        self.insertArray(name, index: index, values: [value])
    }

    /**
    Inserts an array of property values at a given index within the properties current value.

    - parameter name:   The name of the property
    - parameter index:  The index to insert at.
    - parameter values: The values to insert.
    */
    public func insertArray(name:String,index:Int = 0,values:[AnyObject]) {
        if let propertyValue = self[name] {
            if var arrayValue = propertyValue as? [AnyObject] {
                if  index > arrayValue.count {
                    arrayValue.appendContentsOf(values)
                } else {
                    arrayValue.insertContentsOf(values, at: index)
                }
                self[name] = arrayValue
            } else {
                if index > 0 {
                    self[name] = [propertyValue] + values
                } else {
                    self[name] = values + [propertyValue]
                }
            }
        } else {
            self[name] = values
        }
    }

    /**
    Removes the last value of the properties current value.

    - parameter name: The name of the property.
    */
    public func pop(name:String) {
        if var arrayValue = self[name] as? [AnyObject] where arrayValue.count > 0 {
            arrayValue.removeLast()
            self[name] = arrayValue
        }
    }

    /**
    Removes the first value of the properties current value.

    - parameter name: The name of the property.
    */
    public func shift(name:String) {
        if var arrayValue = self[name] as? [AnyObject] where arrayValue.count > 0 {
            arrayValue.removeFirst()
            self[name] = arrayValue
        }
    }

    private func getEntitySpecificProperty(entityProperty: UsergridEntityProperties) -> AnyObject? {
        var propertyValue: AnyObject? = nil
        switch entityProperty {
        case .UUID,.EntityType,.Name :
            propertyValue = self.properties[entityProperty.stringValue]
        case .Created,.Modified :
            if let utcTimeStamp = self.properties[entityProperty.stringValue] as? Int {
                propertyValue = NSDate(utcTimeStamp: utcTimeStamp.description)
            }
        case .Location :
            if let locationDict = self.properties[entityProperty.stringValue] as? [String:Double], lat = locationDict[ENTITY_LATITUDE], long = locationDict[ENTITY_LONGITUDE] {
                propertyValue = CLLocation(latitude: lat, longitude: long)
            }
        }
        return propertyValue
    }

    // MARK: - CRUD Convenience Methods -

    /**
    Performs a GET on the `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter completion: An optional completion block that, if successful, will contain the reloaded `UsergridEntity` object.
    */
    public func reload(completion: UsergridResponseCompletion?) {
        self.reload(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Performs a GET on the `UsergridEntity` using the given instance of `UsergridClient`.

    - parameter client:     The client to use when reloading.
    - parameter completion: An optional completion block that, if successful, will contain the reloaded `UsergridEntity` object.
    */
    public func reload(client:UsergridClient, completion: UsergridResponseCompletion?) {
        if let uuidOrName = self.uuidOrName {
            client.GET(self.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion?(response: UsergridResponse(client: client, errorName: "Entity cannot be reloaded.", errorDescription: "Entity has neither an UUID or specified."))
        }
    }

    /**
    Performs a PUT (or POST if no UUID is found) on the `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter completion: An optional completion block that, if successful, will contain the updated/saved `UsergridEntity` object.
    */
    public func save(completion: UsergridResponseCompletion?) {
        self.save(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Performs a PUT (or POST if no UUID is found) on the `UsergridEntity` using the given instance of `UsergridClient`.

    - parameter client:     The client to use when saving.
    - parameter completion: An optional completion block that, if successful, will contain the updated/saved `UsergridEntity` object.
    */
    public func save(client:UsergridClient, completion: UsergridResponseCompletion?) {
        if let _ = self.uuid { // If UUID exists we PUT otherwise POST
            client.PUT(self, completion: completion)
        } else {
            client.POST(self, completion: completion)
        }
    }

    /**
    Performs a DELETE on the `UsergridEntity` using the shared instance of the `UsergridClient`.

    - parameter completion: An optional completion block.
    */
    public func remove(completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(self, completion: completion)
    }

    /**
    Performs a DELETE on the `UsergridEntity` using the given instance of the `UsergridClient`.

    - parameter client:     The client to use when removing.
    - parameter completion: An optional completion block.
    */
    public func remove(client:UsergridClient, completion: UsergridResponseCompletion?) {
        client.DELETE(self, completion: completion)
    }

    // MARK: - Asset Management -

    /**
    Uploads the given `UsergridAsset` and the data within it and creates an association between this `UsergridEntity` with the given `UsergridAsset` using the shared instance of `UsergridClient`.

    - parameter asset:      The `UsergridAsset` object to upload.
    - parameter progress:   An optional progress block to keep track of upload progress.
    - parameter completion: An optional completion block.
    */
    public func uploadAsset(asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        Usergrid.sharedInstance.uploadAsset(self, asset: asset, progress:progress, completion:completion)
    }

    /**
    Uploads the given `UsergridAsset` and the data within it and creates an association between this `UsergridEntity` with the given `UsergridAsset` using the given instance of `UsergridClient`.

    - parameter client:     The client to use when uploading.
    - parameter asset:      The `UsergridAsset` object to upload.
    - parameter progress:   An optional progress block to keep track of upload progress.
    - parameter completion: An optional completion block.
    */
    public func uploadAsset(client:UsergridClient, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        client.uploadAsset(self, asset: asset, progress:progress, completion:completion)
    }

    /**
    Downloads the `UsergridAsset` that is associated with this `UsergridEntity` using the shared instance of `UsergridClient`.

    - parameter contentType: The content type of the data to load.
    - parameter progress:    An optional progress block to keep track of download progress.
    - parameter completion:  An optional completion block.
    */
    public func downloadAsset(contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        Usergrid.sharedInstance.downloadAsset(self, contentType: contentType, progress:progress, completion: completion)
    }

    /**
    Downloads the `UsergridAsset` that is associated with this `UsergridEntity` using the given instance of `UsergridClient`.

    - parameter client:      The client to use when uploading.
    - parameter contentType: The content type of the data to load.
    - parameter progress:    An optional progress block to keep track of download progress.
    - parameter completion:  An optional completion block.
    */
    public func downloadAsset(client:UsergridClient, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        client.downloadAsset(self, contentType: contentType, progress:progress, completion: completion)
    }

    /**
    Creates a relationship between this `UsergridEntity` and the given entity using the shared instance of `UsergridClient`.

    - parameter relationship: The relationship type.
    - parameter entity:       The entity to connect.
    - parameter completion:   An optional completion block.
    */
    public func connect(relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.CONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    // MARK: - Connection Management -

    /**
    Creates a relationship between this `UsergridEntity` and the given entity using the given instance of `UsergridClient`.

    - parameter client:       The client to use when connecting.
    - parameter relationship: The relationship type.
    - parameter entity:       The entity to connect.
    - parameter completion:   An optional completion block.
    */
    public func connect(client:UsergridClient, relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        client.CONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    /**
    Removes a relationship between this `UsergridEntity` and the given entity using the shared instance of `UsergridClient`.

    - parameter relationship: The relationship type.
    - parameter entity:       The entity to disconnect.
    - parameter completion:   An optional completion block.
    */
    public func disconnect(relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DISCONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    /**
    Removes a relationship between this `UsergridEntity` and the given entity using the given instance of `UsergridClient`.

    - parameter client:       The client to use when disconnecting.
    - parameter relationship: The relationship type.
    - parameter entity:       The entity to disconnect.
    - parameter completion:   An optional completion block.
    */
    public func disconnect(client:UsergridClient, relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        client.DISCONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    /**
    Gets the `UsergridEntity` objects, if any, which are connected via the relationship using the shared instance of `UsergridClient`.

    - parameter relationship: The relationship type.
    - parameter completion:   An optional completion block.
    */
    public func getConnectedEntities(relationship:String, completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.getConnectedEntities(self, relationship: relationship, completion: completion)
    }

    /**
    Gets the `UsergridEntity` objects, if any, which are connected via the relationship using the given instance of `UsergridClient`.

    - parameter client:       The client to use when getting the connected `UsergridEntity` objects.
    - parameter relationship: The relationship type.
    - parameter completion:   An optional completion block.
    */
    public func getConnectedEntities(client:UsergridClient, relationship:String, completion:UsergridResponseCompletion?) {
        client.getConnectedEntities(self, relationship: relationship, completion: completion)
    }
}

private let ENTITY_TYPE = "type"
private let ENTITY_NAME = "name"
private let ENTITY_UUID = "uuid"
private let ENTITY_CREATED = "created"
private let ENTITY_MODIFIED = "modified"
private let ENTITY_LOCATION = "location"

// Sub properties of Location
private let ENTITY_LATITUDE = "latitude"
private let ENTITY_LONGITUDE = "longitude"

/**
`UsergridEntity` specific properties keys.  Note that trying to mutate the values of these properties will not be allowed in most cases.
*/
@objc public enum UsergridEntityProperties : Int {
    case EntityType
    case UUID
    case Name
    case Created
    case Modified
    case Location

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
    public func isMutableForEntity(entity:UsergridEntity) -> Bool {
        switch self {
            case .EntityType,.UUID,.Created,.Modified: return false
            case .Location: return true
            case .Name: return entity.isUser
        }
    }
}