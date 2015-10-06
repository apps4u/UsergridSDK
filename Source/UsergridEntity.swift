//
//  UsergridEntity.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation
import CoreLocation

public class UsergridEntity: NSObject {

    var properties: [String : AnyObject] {
        didSet {
            if let fileMetaData = properties.removeValueForKey(UsergridFileMetaData.FILE_METADATA) as? [String:AnyObject] {
                self.fileMetaData = UsergridFileMetaData(fileMetaDataJSON: fileMetaData)
            } else {
                self.fileMetaData = nil
            }
        }
    }

    public var asset: UsergridAsset?
    private(set) public var fileMetaData : UsergridFileMetaData?

    public var type: String { return self.getEntitySpecificProperty(.EntityType) as! String }
    public var uuid: String? { return self.getEntitySpecificProperty(.UUID) as? String }
    public var name: String? { return self.getEntitySpecificProperty(.Name) as? String }
    public var created: NSDate? { return self.getEntitySpecificProperty(.Created) as? NSDate }
    public var modified: NSDate? { return self.getEntitySpecificProperty(.Modified) as? NSDate }
    public var location: CLLocation? {
        get { return self.getEntitySpecificProperty(.Location) as? CLLocation }
        set { self[UsergridEntityProperties.Location.stringValue] = newValue }
    }

    public var uuidOrName: String? { return self.uuid ?? self.name }
    public var isUser: Bool { return self is UsergridUser || self.type == UsergridUser.USER_ENTITY_TYPE }
    public var hasAsset: Bool { return self.asset != nil || self.fileMetaData?.contentLength > 0 }

    public var jsonObjectValue : [String:AnyObject] { return self.properties }
    public var stringValue : String { return NSString(data: try! NSJSONSerialization.dataWithJSONObject(self.jsonObjectValue, options: NSJSONWritingOptions.PrettyPrinted), encoding: NSASCIIStringEncoding) as! String }

    // MARK: - Initialization -

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

    public class func entities(jsonArray entitiesJSONArray: [[String:AnyObject]]) -> [UsergridEntity] {
        var entityArray : [UsergridEntity] = []
        for entityJSONDict in entitiesJSONArray {
            if let entity = UsergridEntity.entity(jsonDict:entityJSONDict) {
                entityArray.append(entity)
            }
        }
        return entityArray
    }

    // MARK: - Subscript/Entity Properties -

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
                                properties[propertyName] = [UsergridEntity.LATITUDE:location.coordinate.latitude,
                                                            UsergridEntity.LONGITUDE:location.coordinate.longitude]
                            } else if let location = value as? CLLocationCoordinate2D {
                                properties[propertyName] = [UsergridEntity.LATITUDE:location.latitude,
                                                            UsergridEntity.LONGITUDE:location.longitude]
                            } else if let location = value as? [String:Double] {
                                if let lat = location[UsergridEntity.LATITUDE], long = location[UsergridEntity.LONGITUDE] {
                                    properties[propertyName] = [UsergridEntity.LATITUDE:lat,
                                                                UsergridEntity.LONGITUDE:long]
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

    private static let TYPE = "type"
    private static let NAME = "name"
    private static let UUID = "uuid"
    private static let CREATED = "created"
    private static let MODIFIED = "modified"
    private static let LOCATION = "location"

    // Sub properties of Location
    private static let LATITUDE = "latitude"
    private static let LONGITUDE = "latitude"

    @objc public enum UsergridEntityProperties : Int {
        case EntityType
        case UUID
        case Name
        case Created
        case Modified
        case Location

        public static func fromString(stringValue: String) -> UsergridEntityProperties? {
            switch stringValue.lowercaseString {
                case UsergridEntity.TYPE: return .EntityType
                case UsergridEntity.UUID: return .UUID
                case UsergridEntity.NAME: return .Name
                case UsergridEntity.CREATED: return .Created
                case UsergridEntity.MODIFIED: return .Modified
                case UsergridEntity.LOCATION: return .Location
                default: return nil
            }
        }
        public var stringValue: String {
            switch self {
                case .EntityType: return UsergridEntity.TYPE
                case .UUID: return UsergridEntity.UUID
                case .Name: return UsergridEntity.NAME
                case .Created: return UsergridEntity.CREATED
                case .Modified: return UsergridEntity.MODIFIED
                case .Location: return UsergridEntity.LOCATION
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
}

// MARK: - Property Helpers -
extension UsergridEntity {

    public func putProperty(name:String,value:AnyObject) {
        self[name] = value
    }
    public func putProperties(properties:[String:AnyObject]) {
        for (name,value) in properties {
            self.putProperty(name, value: value)
        }
    }
    public func removeProperty(name:String) {
        self[name] = nil
    }
    public func removeProperties(propertyNames:[String]) {
        for name in propertyNames {
            self.removeProperty(name)
        }
    }
    public func push(name:String,value:AnyObject) {
        self.insertArray(name, index: Int.max, values:[value])
    }
    public func append(name:String,values:[AnyObject]) {
        self.insertArray(name, index: Int.max, values: values)
    }
    public func insert(name:String,index:Int = 0,value:AnyObject) {
        self.insertArray(name, index: index, values: [value])
    }
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
    public func pop(name:String) {
        if var arrayValue = self[name] as? [AnyObject] where arrayValue.count > 0 {
            arrayValue.removeLast()
            self[name] = arrayValue
        }
    }
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
                if let locationDict = self.properties[entityProperty.stringValue] as? [String:Double], lat = locationDict["latitude"], long = locationDict["longitude"] {
                    propertyValue = CLLocation(latitude: lat, longitude: long)
                }
        }
        return propertyValue
    }
}

// MARK: - CRUD Convenience Methods -
extension UsergridEntity {

    public func reload(completion: UsergridResponseCompletion?) {
        self.reload(Usergrid.sharedInstance, completion: completion)
    }

    public func reload(client:UsergridClient, completion: UsergridResponseCompletion?) {
        if let uuidOrName = self.uuidOrName {
            client.GET(self.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion?(response: UsergridResponse(client: client, errorName: "Entity cannot be reloaded.", errorDescription: "Entity has neither an UUID or specified."))
        }
    }

    public func save(completion: UsergridResponseCompletion?) {
        self.save(Usergrid.sharedInstance, completion: completion)
    }

    public func save(client:UsergridClient, completion: UsergridResponseCompletion?) {
        if let _ = self.uuid { // If UUID exists we PUT otherwise POST
            client.PUT(self, completion: completion)
        } else {
            client.POST(self, completion: completion)
        }
    }

    public func remove(completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DELETE(self, completion: completion)
    }

    public func remove(client:UsergridClient, completion: UsergridResponseCompletion?) {
        client.DELETE(self, completion: completion)
    }
}

// MARK: - Asset Management -
extension UsergridEntity {

    public func uploadAsset(asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        Usergrid.sharedInstance.uploadAsset(self, asset: asset, progress:progress, completion:completion)
    }

    public func uploadAsset(client:UsergridClient, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        client.uploadAsset(self, asset: asset, progress:progress, completion:completion)
    }

    public func downloadAsset(contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        Usergrid.sharedInstance.downloadAsset(self, contentType: contentType, progress:progress, completion: completion)
    }

    public func downloadAsset(client:UsergridClient, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        client.downloadAsset(self, contentType: contentType, progress:progress, completion: completion)
    }
}

// MARK: - Connection Management -
extension UsergridEntity {

    public func connect(relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.CONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    public func connect(client:UsergridClient, relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        client.CONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    public func disconnect(relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        Usergrid.sharedInstance.DISCONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    public func disconnect(client:UsergridClient, relationship:String, entity:UsergridEntity, completion: UsergridResponseCompletion?) {
        client.DISCONNECT(self, relationship: relationship, connectingEntity: entity, completion: completion)
    }

    public func getConnectedEntities(relationship:String, completion:UsergridResponseCompletion?) {
        Usergrid.sharedInstance.requestManager.getConnectedEntities(self, relationship: relationship, completion: completion)
    }

    public func getConnectedEntities(client:UsergridClient, relationship:String, completion:UsergridResponseCompletion?) {
        client.requestManager.getConnectedEntities(self, relationship: relationship, completion: completion)
    }
}