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
    static let imageLocation = "TestAssets/test.png"
    static let imageName = "test"

    func getFullPathOfFile(fileLocation:String) -> String {
        return (NSBundle(forClass: object_getClass(self)).resourcePath! as NSString).stringByAppendingPathComponent(fileLocation)
    }

    func test_IMAGE_UPLOAD() {
        let getExpect = self.expectationWithDescription("\(__FUNCTION__)")
        let uploadProgress : UsergridAssetProgressBlock = { (bytes,expected) in
            print("UPLOAD PROGRESS BLOCK: BYTES:\(bytes) --- EXPECTED:\(expected)")
        }
        let downloadProgress : UsergridAssetProgressBlock = { (bytes,expected) in
            print("DOWNLOAD PROGRESS BLOCK: BYTES:\(bytes) --- EXPECTED:\(expected)")
        }

        Usergrid.GET(ASSET_Tests.collectionName, uuidOrName:ASSET_Tests.entityUUID) { (response) in
            let entity = response.first!
            XCTAssertNotNil(entity)

            let imagePath = self.getFullPathOfFile(ASSET_Tests.imageLocation)
            XCTAssertNotNil(imagePath)

            let localImage = UIImage(contentsOfFile: imagePath)
            XCTAssertNotNil(localImage)

            let asset = UsergridAsset(fileName:ASSET_Tests.imageName,image: localImage!)
            XCTAssertNotNil(asset)

            entity.uploadAsset(asset: asset!, progress:uploadProgress) { (response, uploadedAsset, error) -> Void in
                XCTAssertNotNil(asset)
                XCTAssertNil(error)
                entity.downloadAsset(contentType: UsergridAsset.ImageContentType.Png.stringValue, progress:downloadProgress)
                { (downloadedAsset, error) -> Void in
                    XCTAssertNotNil(downloadedAsset)
                    XCTAssertNil(error)
                    let downloadedImage = UIImage(data: downloadedAsset!.assetData)
                    XCTAssertEqual(UIImagePNGRepresentation(localImage!), UIImagePNGRepresentation(downloadedImage!))
                    XCTAssertNotNil(downloadedImage)
                    getExpect.fulfill()
                }
            }
        }
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
}
