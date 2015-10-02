//
//  ObjCTests.m
//  UsergridSDK
//
//  Created by Robert Walsh on 9/30/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
@import UsergridSDK;

@interface ObjCTests : XCTestCase
@end

@implementation ObjCTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
//    UsergridEntity* entity = [[UsergridEntity alloc] initWithType:@"" name:@"" propertyDict:nil];

//    NSProgress* progress;
//    [entity uploadAsset:[[UsergridAsset alloc] initWithFileName:@"" data:nil originalLocation:nil contentType:nil]
//               progress:^(int64_t bytesFinished, int64_t totalBytes) {
//
//               } completion:^(UsergridResponse * response, UsergridAsset * asset, NSString * error) {
//
//               }];
//    [entity uploadAsset:[Usergrid shared] asset:nil progress:nil completion:nil];
}

//- (void)testExample {
////    UsergridUserAuth* userAuth = [UsergridUserAuth authWithUsername:@"" password:@""];
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
