//
//  ASSET_Tests.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/24/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import XCTest
@testable import UsergridSDK

class ASSET_Tests: XCTestCase {

    let sharedClient = Usergrid.initialize(ClientCreationTests.orgID, appID: ClientCreationTests.appID)

    static let collectionName = "books"
    static let entityUUID = "f4078aca-2fb1-11e5-8eb2-e13f8369aad1"
    static let imageLocation = "TestAssets/logo_apigee.png"
    static let imageName = "logo_apigee"

    func getFullPathOfFile(fileLocation:String) -> String {
        return (NSBundle(forClass: object_getClass(self)).resourcePath! as NSString).stringByAppendingPathComponent(fileLocation)
    }

    func test_IMAGE_UPLOAD() {
        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        Usergrid.GET(ASSET_Tests.collectionName, uuidOrName:ASSET_Tests.entityUUID) { (response) in
            let entity = response.first!
            XCTAssertNotNil(entity)

            let imagePath = self.getFullPathOfFile(ASSET_Tests.imageLocation)
            XCTAssertNotNil(imagePath)

            let image = UIImage(contentsOfFile: imagePath)
            XCTAssertNotNil(image)

            let asset = UsergridAsset(fileName:ASSET_Tests.imageName,image: image!)
            XCTAssertNotNil(asset)

            entity.uploadAsset(asset: asset!, completion: { (response, uploadedAsset, error) -> Void in
                XCTAssertNotNil(asset)
                XCTAssertNil(error)
                entity.downloadAsset(contentType: UsergridAsset.ImageContentType.Png.stringValue, completion: { (downloadedAsset, error) -> Void in
                    XCTAssertNotNil(asset)
                    XCTAssertNil(error)
                    let downloadedImage = UIImage(data: downloadedAsset!.assetData)
                    XCTAssertEqual(UIImagePNGRepresentation(image!), UIImagePNGRepresentation(downloadedImage!))
                    XCTAssertNotNil(downloadedImage)
                    getExpect.fulfill()
                })
            })
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
