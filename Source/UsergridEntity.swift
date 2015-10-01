//
//  UsergridEntity.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

extension NSDate {
    convenience init(utcTimeStamp: String) {
        self.init(timeIntervalSince1970: (utcTimeStamp as NSString).doubleValue / 1000 )
    }
    func utcTimeStamp() -> Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
}

public class UsergridEntity: NSObject {

    public var type: String { return self.getEntitySpecificProperty(UsergridEntityProperties.EntityType) as! String }
    public var uuid: String? { return self.getEntitySpecificProperty(UsergridEntityProperties.UUID) as? String }
    public var name: String? { return self.getEntitySpecificProperty(UsergridEntityProperties.Name) as? String }
    public var created: NSDate? { return self.getEntitySpecificProperty(UsergridEntityProperties.Created) as? NSDate }
    public var modified: NSDate? { return self.getEntitySpecificProperty(UsergridEntityProperties.Modified) as? NSDate }

    public var uuidOrName: String? { return self.uuid ?? self.name }
    public var isUser: Bool { return self is UsergridUser || self.type == UsergridUser.USER_ENTITY_TYPE }
    public var hasAsset: Bool { return self.asset != nil || self[UsergridEntity.FILE_METADATA] != nil }

    var properties: [String : AnyObject]
    public var asset: UsergridAsset?
    public var downloadAssetProgressBlock: UsergridAssetProgressBlock?
    public var uploadAssetProgressBlock: UsergridAssetProgressBlock?

    public var jsonObjectValue : [String:AnyObject] { return self.properties }
    public var stringValue : String { return NSString(data: try! NSJSONSerialization.dataWithJSONObject(self.jsonObjectValue, options: NSJSONWritingOptions.PrettyPrinted), encoding: NSASCIIStringEncoding) as! String }

    // MARK: - Initialization -

    public init(type:String, name:String? = nil, var propertyDict:[String:AnyObject]? = nil) {
        propertyDict = propertyDict ?? [:]
        self.properties = propertyDict!
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
                if let entityProperty = UsergridEntityProperties.fromString(propertyName) { // All the properties of EntityProperties are immutable so don't set the properties.
                    if entityProperty == UsergridEntityProperties.Name && (self is UsergridUser || self.type == UsergridUser.USER_ENTITY_TYPE) {
                        self.properties[propertyName] = value
                    }
                } else {
                    self.properties[propertyName] = value
                }
            } else {
                // If the property value is nil we assume they wanted to remove the property.
                // We set the value for this property to Null so that when a PUT is performed on the entity the property will actually be removed from the Entity on Usergrid
                self.properties[propertyName] = NSNull()
            }
        }
    }

    private static let FILE_METADATA = "file-metadata"

    private static let TYPE = "type"
    private static let NAME = "name"
    private static let UUID = "uuid"
    private static let CREATED = "created"
    private static let MODIFIED = "modified"

    @objc public enum UsergridEntityProperties : Int {
        case EntityType
        case UUID
        case Name
        case Created
        case Modified

        static func fromString(stringValue: String) -> UsergridEntityProperties? {
            switch stringValue.lowercaseString {
                case UsergridEntity.TYPE: return .EntityType
                case UsergridEntity.UUID: return .UUID
                case UsergridEntity.NAME: return .Name
                case UsergridEntity.CREATED: return .Created
                case UsergridEntity.MODIFIED: return .Modified
                default: return nil
            }
        }
        var stringValue: String {
            switch self {
                case .EntityType: return UsergridEntity.TYPE
                case .UUID: return UsergridEntity.UUID
                case .Name: return UsergridEntity.NAME
                case .Created: return UsergridEntity.CREATED
                case .Modified: return UsergridEntity.MODIFIED
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
        }
        return propertyValue
    }
}

// MARK: - CRUD Convenience Methods -
extension UsergridEntity {

    public func reload(completion: UsergridResponseCompletionBlock) {
        self.reload(Usergrid.shared, completion: completion)
    }

    public func reload(client:UsergridClient, completion: UsergridResponseCompletionBlock) {
        if let uuidOrName = self.uuidOrName {
            client.GET(self.type, uuidOrName: uuidOrName, completion: completion)
        } else {
            completion(response: UsergridResponse(client: client, errorName: "Entity cannot be reloaded.", errorDescription: "No UUID or name found."))
        }
    }

    public func save(completion: UsergridResponseCompletionBlock) {
        self.save(Usergrid.shared, completion: completion)
    }

    public func save(client:UsergridClient, completion: UsergridResponseCompletionBlock) {
        if let _ = self.uuid { // If UUID exists we PUT otherwise POST
            client.PUT(self, completion: completion)
        } else {
            client.POST(self, completion: completion)
        }
    }

    public func remove(completion: UsergridResponseCompletionBlock) {
        self.remove(Usergrid.shared, completion: completion)
    }

    public func remove(client:UsergridClient, completion: UsergridResponseCompletionBlock) {
        client.DELETE(self, completion: completion)
    }
}

// MARK: - Asset Management -
extension UsergridEntity {

    public func uploadAsset(asset:UsergridAsset, progress:UsergridAssetProgressBlock? = nil, completion:UsergridAssetUploadCompletionBlock) {
        self.uploadAsset(Usergrid.shared, asset: asset, progress: progress, completion: completion)
    }

    public func uploadAsset(client:UsergridClient, asset:UsergridAsset, progress:UsergridAssetProgressBlock? = nil, completion:UsergridAssetUploadCompletionBlock) {
        client.requestManager.performUploadAsset(self, asset: asset, progress:progress) { [weak self] (response, asset, error) -> Void in
            self?.asset = asset
            completion(response: response, asset: asset, error: error)
        }
    }

    public func downloadAsset(contentType:String, progress:UsergridAssetProgressBlock? = nil, completion:UsergridAssetDownloadCompletionBlock) {
        self.downloadAsset(Usergrid.shared, contentType: contentType, progress:progress, completion:completion);
    }
    public func downloadAsset(client:UsergridClient, contentType:String, progress:UsergridAssetProgressBlock? = nil, completion:UsergridAssetDownloadCompletionBlock) {
        if self.hasAsset {
            client.requestManager.performGetAsset(self, contentType: contentType, progress:progress) { [weak self] (asset, error) -> Void in
                asset?.contentType = contentType
                self?.asset = asset
                completion(asset: asset, error: error)
            }
        } else {
            completion(asset: nil, error: "Entity does not have an asset attached.")
        }
    }
}

// MARK: - Connection Management -
extension UsergridEntity {

    public func connect(entity:UsergridEntity,relationship:String) {
        self.connect(Usergrid.shared, entity: entity, relationship: relationship)
    }

    public func connect(client:UsergridClient, entity:UsergridEntity,relationship:String) {
        if let _ = self.uuidOrName, _ = entity.uuidOrName {

        }
    }

    public func disconnect(entity:UsergridEntity,relationship:String) {
        self.disconnect(Usergrid.shared, entity: entity, relationship: relationship)
    }

    public func disconnect(client:UsergridClient, entity:UsergridEntity,relationship:String) {
        if let _ = self.uuidOrName, _ = entity.uuidOrName {

        }
    }

    public func disconnectAll(entity:UsergridEntity) {
        self.disconnectAll(Usergrid.shared, entity: entity)
    }

    public func disconnectAll(client:UsergridClient, entity:UsergridEntity) {
        if let _ = self.uuidOrName, _ = entity.uuidOrName {

        }
    }
}