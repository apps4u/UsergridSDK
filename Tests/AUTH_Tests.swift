//
//  AUTH_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/17/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class AUTH_Tests: XCTestCase {

    let testAuthClient = UsergridClient(orgID: ClientCreationTests.orgID, appID: "sdk.demo")
    let clientAuth = UsergridAppAuth(clientID: "b3U6THNcevskEeOQZLcUROUUVA", clientSecret: "b3U6RZHYznP28xieBzQPackFPmmnevU")
    private static let collectionName = "publicevent"
    private static let entityUUID = "fa015eaa-fe1c-11e3-b94b-63b29addea01"

    func test_CLIENT_AUTH() {

        let authExpect = self.expectationWithDescription("\(__FUNCTION__)")
        testAuthClient.authenticateApp(clientAuth) { [weak self] (auth,error) in

            XCTAssertNil(error)
            XCTAssertNotNil(self?.testAuthClient.appAuth)

            if let appAuth = self?.testAuthClient.appAuth {

                XCTAssertNotNil(appAuth.accessToken)
                XCTAssertNotNil(appAuth.expiresIn)

                self?.testAuthClient.GET(AUTH_Tests.collectionName) { (response) in

                    XCTAssertNotNil(response)
                    XCTAssertTrue(response.hasNextPage)
                    XCTAssertEqual(response.entities!.count, 10)
                    XCTAssertEqual(response.first!.type, AUTH_Tests.collectionName)
                    
                    authExpect.fulfill()
                }
            } else {
                authExpect.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }
}
