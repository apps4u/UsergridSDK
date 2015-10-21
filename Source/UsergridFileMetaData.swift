//
//  UsergridFileMetaData.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/6/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

/**
`UsergridFileMetaData` is a helper class for dealing with reading `UsergridEntity` file meta data.
*/
public class UsergridFileMetaData : NSObject {

    internal static let FILE_METADATA = "file-metadata"

    // MARK: - Instance Properties -

    /// The eTag.
    public let eTag: String?

    /// The checkSum.
    public let checkSum: String?

    /// The content type of associated with the file data.
    public let contentType: String?

    /// The content length of associated with the file data.
    public let contentLength: Int

    /// The time stamp for when the file information was last modified.
    public let lastModifiedTimeStamp: Int

    /// The `NSDate` for when the file information was last modified.
    public let lastModifiedDate: NSDate?

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridFileMetaData` objects.

    - parameter fileMetaDataJSON: The file meta data JSON dictionary.

    - returns: A new instance of `UsergridFileMetaData`.
    */
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
