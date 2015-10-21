//
//  User.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class UsergridUser : UsergridEntity {

    static let USER_ENTITY_TYPE = "user"

    public var auth: UsergridUserAuth?

    // Users can change their name property, which is different from other entity types, which is why we provide a getter here.
    override public var name: String? {
        set(name) { self[UsergridUserProperties.Name.stringValue] = name }
        get{ return super.name }
    }
    public var username: String? {
        set(username) { self[UsergridUserProperties.Username.stringValue] = username }
        get { return self.getUserSpecificProperty(.Username) as? String }
    }
    public var password: String? {
        set(password) { self[UsergridUserProperties.Password.stringValue] = password }
        get { return self.getUserSpecificProperty(.Password) as? String }
    }
    public var email: String? {
        set(email) { self[UsergridUserProperties.Email.stringValue] = email }
        get { return self.getUserSpecificProperty(.Email) as? String }
    }
    public var age: NSNumber? {
        set(age) { self[UsergridUserProperties.Age.stringValue] = age }
        get { return self.getUserSpecificProperty(.Age) as? NSNumber }
    }
    public var activated: Bool {
        set(activated) { self[UsergridUserProperties.Activated.stringValue] = activated }
        get { return self.getUserSpecificProperty(.Activated) as? Bool ?? false }
    }
    public var disabled: Bool {
        set(disabled) { self[UsergridUserProperties.Disabled.stringValue] = disabled }
        get { return self.getUserSpecificProperty(.Disabled) as? Bool ?? false }
    }
    public var picture: String? {
        set(picture) { self[UsergridUserProperties.Picture.stringValue] = picture }
        get { return self.getUserSpecificProperty(.Picture) as? String }
    }

    public var uuidOrUsername: String? { return self.uuid ?? self.username }

    public init(name:String? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:nil)
    }

    public init(name:String,propertyDict:[String:AnyObject]? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:propertyDict)
    }

    public func create(completion: UsergridResponseCompletion) {
        self.create(Usergrid.sharedInstance, completion: completion)
    }

    public func create(client: UsergridClient, completion: UsergridResponseCompletion) {
        client.POST(self,completion:completion)
    }

    public func login(username:String, password:String, completion: UsergridUserAuthCompletionBlock) {
        self.login(Usergrid.sharedInstance, username: username, password: password, completion: completion)
    }

    public func login(client: UsergridClient, username:String, password:String, completion: UsergridUserAuthCompletionBlock) {
        let userAuth = UsergridUserAuth(username: username, password: password)
        client.authenticateUser(userAuth,setAsCurrentUser:false) { [weak self] (auth, user, error) -> Void in
            self?.auth = userAuth
            completion(auth: userAuth, user: user, error: error)
        }
    }

    public func logout(completion:UsergridResponseCompletion?) {
        self.logout(Usergrid.sharedInstance,completion:completion)
    }

    public func logout(client: UsergridClient, completion:UsergridResponseCompletion?) {
        if self === client.currentUser {
            client.logoutCurrentUser(completion)
        } else if let uuidOrUsername = self.uuidOrUsername, accessToken = self.auth?.accessToken {
            client.logoutUser(uuidOrUsername, token: accessToken) { (response) in
                self.auth = nil
                completion?(response: response)
            }
        } else {
            completion?(response: UsergridResponse(client:client, errorName:"Logout Failed.", errorDescription:"UUID or Access Token not found on UsergridUser object."))
        }
    }

    private func getUserSpecificProperty(userProperty: UsergridUserProperties) -> AnyObject? {
        var propertyValue: AnyObject? = super[userProperty.stringValue]
        NSJSONReadingOptions.AllowFragments
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
}
