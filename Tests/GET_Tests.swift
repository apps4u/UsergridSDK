//
//  GET_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/2/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class GET_Tests: XCTestCase {

    let usergridClientInstance = UsergridClient(orgID:ClientCreationTests.orgID, appID: ClientCreationTests.appID)

    static let collectionName = "books"
    static let entityUUID = "f4078aca-2fb1-11e5-8eb2-e13f8369aad1"

    let query = UsergridQuery(GET_Tests.collectionName)
        .eq("title", value: "The Sun Also Rises")
        .or()
        .eq("title", value: "The Old Man and the Sea")


    func test_GET_WITHOUT_QUERY() {

        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        usergridClientInstance.GET(GET_Tests.collectionName) { (response) in
            XCTAssertNotNil(response)
            XCTAssertTrue(response.hasNextPage)
            XCTAssertEqual(response.entities!.count, 10)
            getExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test_GET_WITH_QUERY() {

        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        usergridClientInstance.GET(GET_Tests.collectionName, query:self.query) { (response) in
            XCTAssertNotNil(response)
            XCTAssertEqual(response.entities!.count, 3)
            getExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test_GET_WITH_UUID() {

        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        usergridClientInstance.GET(GET_Tests.collectionName, uuidOrName:GET_Tests.entityUUID) { (response) in
            XCTAssertNotNil(response)
            let entity = response.first!
            XCTAssertFalse(response.hasNextPage)
            XCTAssertEqual(response.entities!.count, 1)
            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, GET_Tests.entityUUID)
            getExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test_GET_NEXT_PAGE_WITH_NO_QUERY() {

        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        usergridClientInstance.GET(GET_Tests.collectionName) { (response) in
            XCTAssertNotNil(response)
            XCTAssertTrue(response.hasNextPage)
            XCTAssertEqual(response.entities!.count, 10)

            response.loadNextPage() { (nextPageResponse) in
                XCTAssertNotNil(nextPageResponse)
                XCTAssertFalse(nextPageResponse.hasNextPage)
                XCTAssertEqual(nextPageResponse.entities!.count, 1)
                getExpect.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }
    
}
