//
//  CONNECTION_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/5/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class CONNECTION_Tests: XCTestCase {

    let testAuthClient = UsergridClient(orgID:ClientCreationTests.orgID, appID: "sdk.demo")
    let clientAuth = UsergridAppAuth(clientID: "b3U6THNcevskEeOQZLcUROUUVA", clientSecret: "b3U6RZHYznP28xieBzQPackFPmmnevU")
    private static let collectionName = "publicevent"

    func test_CLIENT_AUTH() {

        let authExpect = self.expectationWithDescription("\(__FUNCTION__)")
        testAuthClient.authenticateApp(clientAuth) { [weak self] (auth,error) in
            XCTAssertNil(error)
            XCTAssertNotNil(self?.testAuthClient.appAuth)

            if let appAuth = self?.testAuthClient.appAuth {

                XCTAssertNotNil(appAuth.accessToken)
                XCTAssertNotNil(appAuth.expiresIn)

                self?.testAuthClient.GET(CONNECTION_Tests.collectionName) { (response) in

                    XCTAssertNotNil(response)
                    XCTAssertTrue(response.hasNextPage)
                    XCTAssertEqual(response.entities!.count, 10)

                    let entity = response.first!
                    let entityToConnect = response.entities![1]
                    XCTAssertEqual(entity.type, CONNECTION_Tests.collectionName)

                    entity.connect(self!.testAuthClient,relationship:"likes", entity: entityToConnect) { (response) -> Void in
                        XCTAssertNotNil(response)
                        entity.getConnectedEntities(self!.testAuthClient, relationship: "likes") { (response) -> Void in
                            XCTAssertNotNil(response)
                            let connectedEntity = response.first!
                            XCTAssertNotNil(connectedEntity)
                            XCTAssertEqual(connectedEntity.uuidOrName, entityToConnect.uuidOrName)
                            entity.disconnect(self!.testAuthClient, relationship: "likes", entity: connectedEntity) { (response) -> Void in
                                XCTAssertNotNil(response)
                                entity.getConnectedEntities(self!.testAuthClient, relationship: "likes") { (response) -> Void in
                                    XCTAssertNotNil(response)
                                    XCTAssertNil(response.first)
                                    authExpect.fulfill()
                                }
                            }
                        }
                    }
                }
            } else {
                authExpect.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }
}
