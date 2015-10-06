//
//  ClientCreationTests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/31/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class ClientCreationTests: XCTestCase {

    static let orgID = "rwalsh"
    static let appID = "sandbox"

    static let otherInstanceID = "otherInstanceID"
    static let otherAppID = "otherAppID"
    static let otherOrgID = "otherOrgID"
    static let otherBaseURL = "http://www.something.com"
    static let otherAppAuth = UsergridAppAuth(clientID: "alkdjflsdf", clientSecret: "alkdjflsdf")

    static let otherConfiguration = UsergridClientConfig(orgID: ClientCreationTests.otherOrgID,
                                                         appID: ClientCreationTests.otherAppID,
                                                         baseURL: ClientCreationTests.otherBaseURL,
                                                         authFallback: .None,
                                                         appAuth: ClientCreationTests.otherAppAuth)

    let sharedClient = Usergrid.initSharedInstance(orgID:ClientCreationTests.orgID, appID: ClientCreationTests.appID)
    let otherClient = UsergridClient(configuration: ClientCreationTests.otherConfiguration)

    func test_INSTANCES_EXIST() {
        XCTAssertNotNil(sharedClient)
        XCTAssertNotNil(Usergrid.sharedInstance)
        XCTAssertNotNil(otherClient)
    }

    func test_GET_INSTANCES() {
        XCTAssertTrue(sharedClient === Usergrid.sharedInstance)
        XCTAssertFalse(otherClient === sharedClient)
    }

    func test_CLIENT_PROPERTIES() {
        XCTAssertEqual(sharedClient.appID, ClientCreationTests.appID)
        XCTAssertEqual(sharedClient.orgID, ClientCreationTests.orgID)
        XCTAssertEqual(sharedClient.authFallback, UsergridAuthFallback.App)
        XCTAssertEqual(sharedClient.baseURL, UsergridClient.DEFAULT_BASE_URL)
        XCTAssertNil(sharedClient.currentUser)

        XCTAssertEqual(otherClient.appID, ClientCreationTests.otherAppID)
        XCTAssertEqual(otherClient.orgID, ClientCreationTests.otherOrgID)
        XCTAssertEqual(otherClient.authFallback, UsergridAuthFallback.None)
        XCTAssertEqual(otherClient.baseURL, ClientCreationTests.otherBaseURL)
        XCTAssertNil(otherClient.currentUser)
    }
}
