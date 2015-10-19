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

    let otherClient = UsergridClient(configuration: ClientCreationTests.otherConfiguration)

    override func setUp() {
        super.setUp()
        Usergrid.initSharedInstance(orgID:ClientCreationTests.orgID, appID: ClientCreationTests.appID)
    }

    override func tearDown() {
        Usergrid._sharedClient = nil
        super.tearDown()
    }

    func test_INSTANCE_POINTERS() {
        XCTAssertNotNil(Usergrid.sharedInstance)
        XCTAssertNotNil(otherClient)
        XCTAssertFalse(otherClient === Usergrid.sharedInstance)
    }

    func test_CLIENT_PROPERTIES() {
        XCTAssertEqual(Usergrid.sharedInstance.appID, ClientCreationTests.appID)
        XCTAssertEqual(Usergrid.sharedInstance.orgID, ClientCreationTests.orgID)
        XCTAssertEqual(Usergrid.sharedInstance.authFallback, UsergridAuthFallback.App)
        XCTAssertEqual(Usergrid.sharedInstance.baseURL, UsergridClient.DEFAULT_BASE_URL)
        XCTAssertNil(Usergrid.sharedInstance.currentUser)

        XCTAssertEqual(otherClient.appID, ClientCreationTests.otherAppID)
        XCTAssertEqual(otherClient.orgID, ClientCreationTests.otherOrgID)
        XCTAssertEqual(otherClient.authFallback, UsergridAuthFallback.None)
        XCTAssertEqual(otherClient.baseURL, ClientCreationTests.otherBaseURL)
        XCTAssertNil(otherClient.currentUser)
    }
}
