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

    static let orgId = "rwalsh"
    static let appId = "sandbox"

    static let otherInstanceID = "otherInstanceID"
    static let otherAppID = "otherAppID"
    static let otherOrgID = "otherOrgID"
    static let otherBaseURL = "http://www.something.com"
    static let otherAppAuth = UsergridAppAuth(clientId: "alkdjflsdf", clientSecret: "alkdjflsdf")

    static let otherConfiguration = UsergridClientConfig(orgId: ClientCreationTests.otherOrgID,
                                                         appId: ClientCreationTests.otherAppID,
                                                         baseUrl: ClientCreationTests.otherBaseURL,
                                                         authFallback: .None,
                                                         appAuth: ClientCreationTests.otherAppAuth)

    let otherClient = UsergridClient(configuration: ClientCreationTests.otherConfiguration)

    override func setUp() {
        super.setUp()
        Usergrid.initSharedInstance(orgId:ClientCreationTests.orgId, appId: ClientCreationTests.appId)
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
        XCTAssertEqual(Usergrid.sharedInstance.appId, ClientCreationTests.appId)
        XCTAssertEqual(Usergrid.sharedInstance.orgId, ClientCreationTests.orgId)
        XCTAssertEqual(Usergrid.sharedInstance.authFallback, UsergridAuthFallback.App)
        XCTAssertEqual(Usergrid.sharedInstance.baseUrl, UsergridClient.DEFAULT_BASE_URL)
        XCTAssertNil(Usergrid.sharedInstance.currentUser)

        XCTAssertEqual(otherClient.appId, ClientCreationTests.otherAppID)
        XCTAssertEqual(otherClient.orgId, ClientCreationTests.otherOrgID)
        XCTAssertEqual(otherClient.authFallback, UsergridAuthFallback.None)
        XCTAssertEqual(otherClient.baseUrl, ClientCreationTests.otherBaseURL)
        XCTAssertNil(otherClient.currentUser)
    }

    func test_CLIENT_NSCODING() {
        let sharedInstanceAsData = NSKeyedArchiver.archivedDataWithRootObject(Usergrid.sharedInstance)
        let newInstanceFromData = NSKeyedUnarchiver.unarchiveObjectWithData(sharedInstanceAsData) as? UsergridClient

        XCTAssertNotNil(newInstanceFromData)

        if let newInstance = newInstanceFromData {
            XCTAssertEqual(Usergrid.sharedInstance.appId, newInstance.appId)
            XCTAssertEqual(Usergrid.sharedInstance.orgId, newInstance.orgId)
            XCTAssertEqual(Usergrid.sharedInstance.authFallback, newInstance.authFallback)
            XCTAssertEqual(Usergrid.sharedInstance.baseUrl, newInstance.baseUrl)
        }
    }
}
