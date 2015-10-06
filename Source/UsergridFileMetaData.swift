//
//  UsergridFileMetaData.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/6/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

public class UsergridFileMetaData : NSObject {

    internal static let FILE_METADATA = "file-metadata"

    public let eTag: String?
    public let checkSum: String?
    public let contentType: String?
    public let contentLength: Int
    public let lastModifiedTimeStamp: Int
    public let lastModifiedDate: NSDate?

    public init(fileMetaDataJSON:[String:AnyObject]) {
        self.eTag = fileMetaDataJSON["etag"] as? String
        self.checkSum = fileMetaDataJSON["checksum"] as? String
        self.contentType = fileMetaDataJSON["content-type"] as? String
        self.contentLength = fileMetaDataJSON["content-length"] as? Int ?? 0
        self.lastModifiedTimeStamp = fileMetaDataJSON["last-modified"] as? Int ?? 0
        if self.lastModifiedTimeStamp > 0 {
            self.lastModifiedDate = NSDate(utcTimeStamp: self.lastModifiedTimeStamp.description)
        } else {
            self.lastModifiedDate = nil
        }
    }
}
