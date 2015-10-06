//
//  ApigeeSDKTests.swift
//  Tests
//
//  Created by Robert Walsh on 7/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class ApigeeSDKTests: XCTestCase {

    let sharedClient = Usergrid.initSharedInstance(orgID:ClientCreationTests.orgID, appID: ClientCreationTests.appID)

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
}
