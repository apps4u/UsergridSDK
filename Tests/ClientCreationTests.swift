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

    let sharedClient = Usergrid.initialize(ClientCreationTests.orgID, appID: ClientCreationTests.appID)
    let otherClient = UsergridClient().initialize([UsergridClient.Config.orgID:ClientCreationTests.otherOrgID,UsergridClient.Config.appID:ClientCreationTests.otherAppID,UsergridClient.Config.url:otherBaseURL,UsergridClient.Config.authFallback:UsergridClient.AuthFallback.NONE.rawValue])

    func test_INSTANCES_EXIST() {
        XCTAssertNotNil(sharedClient)
        XCTAssertNotNil(Usergrid.shared)
        XCTAssertNotNil(otherClient)
    }

    func test_GET_INSTANCES() {
        XCTAssertTrue(sharedClient === Usergrid.shared)
        XCTAssertFalse(otherClient === sharedClient)
    }

    func test_CLIENT_PROPERTIES() {
        XCTAssertEqual(sharedClient.appID, ClientCreationTests.appID)
        XCTAssertEqual(sharedClient.orgID, ClientCreationTests.orgID)
        XCTAssertEqual(sharedClient.authFallback, UsergridClient.AuthFallback.APP)
        XCTAssertEqual(sharedClient.baseURL, UsergridClient.DEFAULT_BASE_URL)
        XCTAssertNil(sharedClient.currentUser)

        XCTAssertEqual(otherClient.appID, ClientCreationTests.otherAppID)
        XCTAssertEqual(otherClient.orgID, ClientCreationTests.otherOrgID)
        XCTAssertEqual(otherClient.authFallback, UsergridClient.AuthFallback.NONE)
        XCTAssertEqual(otherClient.baseURL, ClientCreationTests.otherBaseURL)
        XCTAssertNil(otherClient.currentUser)
    }
}
