//
//  UsergridClientConfig.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/5/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

public class UsergridClientConfig : NSObject {

    public let orgID : String
    public let appID : String

    public var baseURL: String = UsergridClient.DEFAULT_BASE_URL
    public var authFallback: UsergridAuthFallback = .None
    public var appAuth: UsergridAppAuth?

    public init(orgID: String, appID: String) {
        self.orgID = orgID
        self.appID = appID
    }

    public convenience init(orgID: String, appID: String, baseURL:String) {
        self.init(orgID:orgID,appID:appID)
        self.baseURL = baseURL
    }

    public convenience init(orgID: String, appID: String, baseURL:String, authFallback:UsergridAuthFallback, appAuth:UsergridAppAuth? = nil) {
        self.init(orgID:orgID,appID:appID,baseURL:baseURL)
        self.authFallback = authFallback
        self.appAuth = appAuth
    }
}
