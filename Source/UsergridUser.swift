//
//  User.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class UsergridUser : UsergridEntity {

    public var auth: UsergridUserAuth?

    // Users can change their name property, which is different from other entity types, which is why we provide a getter here.
    override public var name: String? {
        set(name) { self[UsergridUserProperties.Name.stringValue] = name }
        get{ return super.name }
    }
    public var username: String? {
        set(username) { self[UsergridUserProperties.Username.stringValue] = username }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Username) as? String }
    }
    public var password: String? {
        set(password) { self[UsergridUserProperties.Password.stringValue] = password }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Password) as? String }
    }
    public var email: String? {
        set(email) { self[UsergridUserProperties.Email.stringValue] = email }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Email) as? String }
    }
    public var age: NSNumber? {
        set(age) { self[UsergridUserProperties.Age.stringValue] = age }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Age) as? NSNumber }
    }
    public var activated: Bool {
        set(activated) { self[UsergridUserProperties.Activated.stringValue] = activated }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Activated) as? Bool ?? false }
    }
    public var disabled: Bool {
        set(disabled) { self[UsergridUserProperties.Disabled.stringValue] = disabled }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Disabled) as? Bool ?? false }
    }
    public var picture: String? {
        set(picture) { self[UsergridUserProperties.Picture.stringValue] = picture }
        get { return self.getUserSpecificProperty(UsergridUserProperties.Picture) as? String }
    }

    public init(name:String? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:nil)
    }

    public init(name:String,propertyDict:[String:AnyObject]? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:propertyDict)
    }

    public func create(completion: UsergridResponseCompletionBlock) {
        self.create(Usergrid.shared, completion: completion)
    }

    public func create(client: UsergridClient, completion: UsergridResponseCompletionBlock) {
        client.POST(self,completion:completion)
    }

    public func login(username:String, password:String, completion: UsergridUserAuthCompletionBlock) {
        self.login(Usergrid.shared, username: username, password: password, completion: completion)
    }

    public func login(client: UsergridClient, username:String, password:String, completion: UsergridUserAuthCompletionBlock) {
        let userAuth = UsergridUserAuth(username: username, password: password)
        client.authenticateUser(userAuth,setAsCurrentUser:false) { [weak self] (auth, user, error) -> Void in
            self?.auth = userAuth
            completion(auth: userAuth, user: user, error: error)
        }
    }

    public func logout() {
        self.logout(Usergrid.shared)
    }

    public func logout(client: UsergridClient) {
        self.auth = nil
        if self === client.currentUser {
            client.currentUser = nil
        }
    }

    public func getUserSpecificProperty(userProperty: UsergridUserProperties) -> AnyObject? {
        var propertyValue: AnyObject? = super[userProperty.stringValue]
        switch userProperty {
            case .Activated,.Disabled :
                propertyValue = propertyValue?.boolValue
            case .Age :
                propertyValue = propertyValue?.integerValue
            case .Name,.Username,.Password,.Email,.Picture :
                break
        }
        return propertyValue
    }

    override public subscript(propertyName: String) -> AnyObject? {
        get {
            if let userProperty = UsergridUserProperties.fromString(propertyName) {
                return self.getUserSpecificProperty(userProperty)
            } else {
                return super[propertyName]
            }
        }
        set(propertyValue) {
            super[propertyName] = propertyValue
        }
    }

    static let USER_ENTITY_TYPE = "user"
    
    private static let NAME = "name"
    private static let USERNAME = "username"
    private static let PASSWORD = "password"
    private static let EMAIL = "email"
    private static let AGE = "age"
    private static let ACTIVATED = "activated"
    private static let DISABLED = "disabled"
    private static let PICTURE = "picture"

    @objc public enum UsergridUserProperties: Int {
        case Name; case Username; case Password; case Email; case Age; case Activated; case Disabled; case Picture
        static func fromString(stringValue: String) -> UsergridUserProperties? {
            switch stringValue.lowercaseString {
                case UsergridUser.NAME: return .Name
                case UsergridUser.USERNAME: return .Username
                case UsergridUser.PASSWORD: return .Password
                case UsergridUser.EMAIL: return .Email
                case UsergridUser.AGE: return .Age
                case UsergridUser.ACTIVATED: return .Activated
                case UsergridUser.DISABLED: return .Disabled
                case UsergridUser.PICTURE: return .Picture
                default: return nil
            }
        }
        var stringValue: String {
            switch self {
                case .Name: return UsergridUser.NAME
                case .Username: return UsergridUser.USERNAME
                case .Password: return UsergridUser.PASSWORD
                case .Email: return UsergridUser.EMAIL
                case .Age: return UsergridUser.AGE
                case .Activated: return UsergridUser.ACTIVATED
                case .Disabled: return UsergridUser.DISABLED
                case .Picture: return UsergridUser.PICTURE
            }
        }
    }
}