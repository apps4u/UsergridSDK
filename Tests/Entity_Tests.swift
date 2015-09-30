//
//  Entity_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/22/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class Entity_Tests: XCTestCase {

    let entity = UsergridEntity(type: "", name:"")
    let customArrayName = "customArray"
    let customArrayOriginalValue = [1,2,3,4,5]
    let customPropertyName = "customProperty"
    let customPropertyValue = 99

    func test_PUT_PROPERTY() {

        entity.putProperty(customArrayName, value: customArrayOriginalValue)

        let propertyValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(propertyValue)
        XCTAssertEqual(propertyValue!, customArrayOriginalValue)
    }
    func test_PUT_PROPERTIES() {

        entity.putProperties([customArrayName:customArrayOriginalValue])

        let propertyValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(propertyValue)
        XCTAssertEqual(propertyValue!, customArrayOriginalValue)
    }
    func test_REMOVE_PROPERTY() {
        entity[customArrayName] = customArrayOriginalValue
        let propertyValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(propertyValue)

        entity.removeProperty(customArrayName)

        XCTAssertNil(entity[customArrayName])
    }
    func test_REMOVE_PROPERTIES() {
        entity[customArrayName] = customArrayOriginalValue
        let propertyValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(propertyValue)

        entity.removeProperties([customArrayName])

        XCTAssertNil(entity[customArrayName])
    }
    func test_PUSH() {
        entity[customArrayName] = customArrayOriginalValue

        entity.push(customArrayName,value:6)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,2,3,4,5,6])
    }
    func test_APPEND() {
        entity[customArrayName] = customArrayOriginalValue

        entity.append(customArrayName,values:[6,7])

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,2,3,4,5,6,7])
    }
    func test_INSERT_WITHOUT_INDEX() {
        entity[customArrayName] = customArrayOriginalValue

        entity.insert(customArrayName,value:6)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [6,1,2,3,4,5])
    }
    func test_INSERT_WITH_INDEX() {
        entity[customArrayName] = customArrayOriginalValue

        entity.insert(customArrayName,index:1,value:6)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,6,2,3,4,5])
    }
    func test_INSERT_ARRAY_WITHOUT_INDEX() {
        entity[customArrayName] = customArrayOriginalValue

        entity.insertArray(customArrayName,values:[6,7])

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [6,7,1,2,3,4,5])
    }
    func test_INSERT_ARRAY_WITH_INDEX() {
        entity[customArrayName] = customArrayOriginalValue

        entity.insertArray(customArrayName,index:1,values:[6,7])

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,6,7,2,3,4,5])
    }
    func test_INSERT_ARRAY_TO_NON_EXISTENT_PROPERTY() {
        entity.insertArray(customArrayName,values:customArrayOriginalValue)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,2,3,4,5])
    }
    func test_INSERT_ARRAY_TO_NON_ARRAY_PROPERTY_WITHOUT_INDEX() {
        entity[customPropertyName] = customPropertyValue

        entity.insertArray(customPropertyName,values:customArrayOriginalValue)

        let newValue = entity[customPropertyName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,2,3,4,5,99])
    }
    func test_INSERT_ARRAY_TO_NON_ARRAY_PROPERTY_WITH_INDEX() {
        entity[customPropertyName] = customPropertyValue

        entity.insertArray(customPropertyName,index:1,values:customArrayOriginalValue)

        let newValue = entity[customPropertyName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [99,1,2,3,4,5])
    }
    func test_POP() {
        entity[customArrayName] = customArrayOriginalValue

        entity.pop(customArrayName)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [1,2,3,4])
    }
    func test_SHIFT() {
        entity[customArrayName] = customArrayOriginalValue

        entity.shift(customArrayName)

        let newValue = entity[customArrayName] as? [Int]
        XCTAssertNotNil(newValue)
        XCTAssertEqual(newValue!, [2,3,4,5])
    }
}
