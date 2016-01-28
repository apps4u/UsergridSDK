//
//  UsergridExtensions.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/6/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

internal extension NSDate {
    convenience init(utcTimeStamp: String) {
        self.init(timeIntervalSince1970: (utcTimeStamp as NSString).doubleValue / 1000 )
    }
    func utcTimeStamp() -> Int {
        return Int(self.timeIntervalSince1970 * 1000)
    }
}

internal extension String {
    func isUuid() -> Bool {
        return (NSUUID(UUIDString: self) != nil) ? true : false
    }
}