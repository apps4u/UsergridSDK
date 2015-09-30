//
//  PUT_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/11/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class PUT_Tests: XCTestCase {

    let sharedClient = Usergrid.initialize(ClientCreationTests.orgID, appID: ClientCreationTests.appID)

    let query = UsergridQuery(PUT_Tests.collectionName)
        .eq("title", value: "The Sun Also Rises")
        .or()
        .eq("title", value: "The Old Man and the Sea")

    static let collectionName = "books"
    static let entityUUID = "f4078aca-2fb1-11e5-8eb2-e13f8369aad1"

    func test_PUT_BY_SPECIFYING_UUID_AS_PARAMETER() {

        let propertyNameToUpdate = "\(__FUNCTION__)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectationWithDescription(propertyNameToUpdate)

        Usergrid.PUT(PUT_Tests.collectionName, uuidOrName: PUT_Tests.entityUUID, jsonBody:[propertyNameToUpdate : propertiesNewValue]) { (response) in

            XCTAssertNotNil(response)
            XCTAssertEqual(response.entities!.count, 1)
            let entity = response.first!

            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, PUT_Tests.entityUUID)

            let updatedPropertyValue = entity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test_PUT_BY_SPECIFYING_UUID_WITHIN_JSON_BODY() {

        let propertyNameToUpdate = "\(__FUNCTION__)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectationWithDescription(propertyNameToUpdate)

        let jsonDictToPut = [UsergridEntity.UsergridEntityProperties.UUID.stringValue : PUT_Tests.entityUUID, propertyNameToUpdate : propertiesNewValue]

        Usergrid.PUT(PUT_Tests.collectionName, jsonBody: jsonDictToPut) { (response) in
            XCTAssertNotNil(response)
            XCTAssertEqual(response.entities!.count, 1)
            let entity = response.first!

            XCTAssertNotNil(entity)
            XCTAssertEqual(entity.uuid!, PUT_Tests.entityUUID)

            let updatedPropertyValue = entity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test_PUT_WITH_ENTITY_OBJECT() {
        let propertyNameToUpdate = "\(__FUNCTION__)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectationWithDescription(propertyNameToUpdate)

        Usergrid.GET(PUT_Tests.collectionName, uuidOrName: PUT_Tests.entityUUID) { (getResponse) in
            XCTAssertNotNil(getResponse)
            XCTAssertEqual(getResponse.entities!.count, 1)

            var responseEntity = getResponse.first!

            XCTAssertNotNil(responseEntity)
            XCTAssertEqual(responseEntity.uuid!, PUT_Tests.entityUUID)

            responseEntity[propertyNameToUpdate] = propertiesNewValue

            Usergrid.PUT(responseEntity) { (putResponse) in
                XCTAssertNotNil(putResponse)
                XCTAssertEqual(putResponse.entities!.count, 1)
                responseEntity = putResponse.first!

                XCTAssertNotNil(responseEntity)
                XCTAssertEqual(responseEntity.uuid!, PUT_Tests.entityUUID)

                let updatedPropertyValue = responseEntity[propertyNameToUpdate] as? String
                XCTAssertNotNil(updatedPropertyValue)
                XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
                putExpect.fulfill()
            }
        }
        self.waitForExpectationsWithTimeout(20, handler: nil)
    }

    func test_PUT_WITH_QUERY() {
        let propertyNameToUpdate = "\(__FUNCTION__)"
        let propertiesNewValue = "\(propertyNameToUpdate)_VALUE"
        let putExpect = self.expectationWithDescription(propertyNameToUpdate)

        Usergrid.PUT(self.query, jsonBody: [propertyNameToUpdate : propertiesNewValue]) { (putResponse) in
            XCTAssertNotNil(putResponse)
            XCTAssertEqual(putResponse.entities!.count, 3)

            let responseEntity = putResponse.first!
            XCTAssertNotNil(responseEntity)

            let updatedPropertyValue = responseEntity[propertyNameToUpdate] as? String
            XCTAssertNotNil(updatedPropertyValue)
            XCTAssertEqual(updatedPropertyValue!,propertiesNewValue)
            putExpect.fulfill()
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
