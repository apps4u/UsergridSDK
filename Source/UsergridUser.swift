//
//  User.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

/**
`UsergridUser` is a special subclass of `UsergridEntity` that supports functions and properties unique to users.
*/
public class UsergridUser : UsergridEntity {

    static let USER_ENTITY_TYPE = "user"

    // MARK: - Instance Properties -

    /// The `UsergridUserAuth` object if this user was authenticated.
    public var auth: UsergridUserAuth?

    /** 
    Property helper method for the `UsergridUser` objects `UsergridUserProperties.Name`.
    
    Unlike `UsergridEntity` objects, `UsergridUser`'s can change their name property which is why we provide a getter here.
    */
    override public var name: String? {
        set(name) { self[UsergridUserProperties.Name.stringValue] = name }
        get{ return super.name }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Username`.
    public var username: String? {
        set(username) { self[UsergridUserProperties.Username.stringValue] = username }
        get { return self.getUserSpecificProperty(.Username) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Password`.
    public var password: String? {
        set(password) { self[UsergridUserProperties.Password.stringValue] = password }
        get { return self.getUserSpecificProperty(.Password) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Email`.
    public var email: String? {
        set(email) { self[UsergridUserProperties.Email.stringValue] = email }
        get { return self.getUserSpecificProperty(.Email) as? String }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Age`.
    public var age: NSNumber? {
        set(age) { self[UsergridUserProperties.Age.stringValue] = age }
        get { return self.getUserSpecificProperty(.Age) as? NSNumber }
    }

    /** 
    Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Activated`.
    
    Indicates whether the user account has been activated or not.
    */
    public var activated: Bool {
        set(activated) { self[UsergridUserProperties.Activated.stringValue] = activated }
        get { return self.getUserSpecificProperty(.Activated) as? Bool ?? false }
    }

    /// Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Disabled`.
    public var disabled: Bool {
        set(disabled) { self[UsergridUserProperties.Disabled.stringValue] = disabled }
        get { return self.getUserSpecificProperty(.Disabled) as? Bool ?? false }
    }

    /**
    Property getter and setter helpers for the `UsergridUser` objects `UsergridUserProperties.Picture`.
    
    URL path to user’s profile picture. Defaults to Gravatar for email address.
    */
    public var picture: String? {
        set(picture) { self[UsergridUserProperties.Picture.stringValue] = picture }
        get { return self.getUserSpecificProperty(.Picture) as? String }
    }

    /// The UUID or username property value if found.
    public var uuidOrUsername: String? { return self.uuid ?? self.username }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridUser` objects.

    - parameter name: The name of the user.  Note this is different from the `username` property.

    - returns: A new instance of `UsergridUser`.
    */
    public init(name:String? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:nil)
    }

    /**
    Designated initializer for `UsergridUser` objects.

    - parameter name:         The name of the user.  Note this is different from the `username` property.
    - parameter propertyDict: The optional property dictionary that the `UsergridEntity` object will start out with.

    - returns: A new instance of `UsergridUser`.
    */
    public init(name:String,propertyDict:[String:AnyObject]? = nil) {
        super.init(type: UsergridUser.USER_ENTITY_TYPE, name:name, propertyDict:propertyDict)
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        self.auth = aDecoder.decodeObjectForKey("auth") as? UsergridUserAuth
        super.init(coder: aDecoder)
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.auth, forKey: "auth")
        super.encodeWithCoder(aCoder)
    }

    // MARK: - Instance Methods -

    /**
    Creates the user object in Usergrid if the user does not already exist with the shared instance of `UsergridClient`.

    - parameter completion: The optional completion block.
    */
    public func create(completion: UsergridResponseCompletion?) {
        self.create(Usergrid.sharedInstance, completion: completion)
    }

    /**
    Creates the user object in Usergrid if the user does not already exist with the given `UsergridClient`.

    - parameter client:     The client to use for creation.
    - parameter completion: The optional completion block.
    */
    public func create(client: UsergridClient, completion: UsergridResponseCompletion?) {
        client.POST(self,completion:completion)
    }

    /**
    Authenticates the specified user using the provided username and password with the shared instance of `UsergridClient`.

    While functionally similar to `UsergridClient.authenticateUser(auth)`, this method does not automatically assign this user to `UsergridClient.currentUser`:

    - parameter username:   The username.
    - parameter password:   The password.
    - parameter completion: The optional completion block.
    */
    public func login(username:String, password:String, completion: UsergridUserAuthCompletionBlock?) {
        self.login(Usergrid.sharedInstance, username: username, password: password, completion: completion)
    }

    /**
    Authenticates the specified user using the provided username and password.

    While functionally similar to `UsergridClient.authenticateUser(auth)`, this method does not automatically assign this user to `UsergridClient.currentUser`:

    - parameter client:     The client to use for login.
    - parameter username:   The username.
    - parameter password:   The password.
    - parameter completion: The optional completion block.
    */
    public func login(client: UsergridClient, username:String, password:String, completion: UsergridUserAuthCompletionBlock?) {
        let userAuth = UsergridUserAuth(username: username, password: password)
        client.authenticateUser(userAuth,setAsCurrentUser:false) { [weak self] (auth, user, error) -> Void in
            self?.auth = userAuth
            completion?(auth: userAuth, user: user, error: error)
        }
    }

    /**
     Attmepts to reauthenticate using the user's `UsergridUserAuth` instance property with the shared instance of `UsergridClient`.

     - parameter completion: The optional completion block.
     */
    public func reauthenticate(completion: UsergridUserAuthCompletionBlock? = nil) {
        self.reauthenticate(Usergrid.sharedInstance, completion: completion)
    }

    /**
     Attmepts to reauthenticate using the user's `UsergridUserAuth` instance property.

     - parameter client:     The client to use for reauthentication.
     - parameter completion: The optional completion block.
     */
    public func reauthenticate(client: UsergridClient, completion: UsergridUserAuthCompletionBlock? = nil) {
        if let userAuth = self.auth {
            client.authenticateUser(userAuth, completion: completion)
        } else {
            completion?(auth: nil, user: self, error: "No UsergridUserAuth found on the UsergridUser.")
        }
    }

    /**
    Invalidates the user token locally and remotely.

    - parameter completion: The optional completion block.
    */
    public func logout(completion:UsergridResponseCompletion?) {
        self.logout(Usergrid.sharedInstance,completion:completion)
    }

    /**
    Invalidates the user token locally and remotely.

    - parameter client:     The client to use for logout.
    - parameter completion: The optional completion block.
    */
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

    /**
    Subscript for the `UsergridUser` class.

    - Warning: When setting a properties value must be a valid JSON object.

    - Example usage:
    ```
    let someName = usergridUser["name"]
    
    usergridUser["name"] = someName
    ```
    */
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