//
//  UsergridAsset.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/21/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

/// The progress block used in `UsergridAsset` are being uploaded or downloaded.
public typealias UsergridAssetRequestProgress = (bytesFinished:Int64, bytesExpected: Int64) -> Void

/// The completion block used in `UsergridAsset` are finished uploading.
public typealias UsergridAssetUploadCompletion = (response:UsergridResponse,asset:UsergridAsset?, error: String?) -> Void

/// The completion block used in `UsergridAsset` are finished downloading.
public typealias UsergridAssetDownloadCompletion = (asset:UsergridAsset?, error: String?) -> Void

/**
As Usergrid supports storing binary assets, the SDKs are designed to make uploading assets easier and more robust. Attaching, uploading, and downloading assets is handled by the `UsergridEntity` class.

Unless defined, whenever possible, the content-type will be inferred from the data provided, and the attached file (if not already a byte-array representation) will be binary-encoded.
*/
public class UsergridAsset: NSObject, NSCoding {

    private static let DEFAULT_FILE_NAME = "file"

    // MARK: - Instance Properties -

    /// The filename to be used in the multipart/form-data request.
    public let fileName: String

    /// Binary representation of asset data. If an image or image path was passed on initialization of the `UsergridAsset`.
    public let assetData: NSData

    /// A representation of the folder location the asset was loaded from, if it was provided in the initialization.
    public let originalLocation: String?

    /// The Content-type of the asset to be used when defining content-type inside the multipart/form-data request.
    public var contentType: String

    ///  The content length of the assets data.
    public var contentLength: Int { return self.assetData.length }
    
    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridAsset` objects.

    - parameter fileName:         The file name associated with the file data.
    - parameter data:             The data of the file.
    - parameter originalLocation: An optional original location of the file.
    - parameter contentType:      The content type of the file.

    - returns: A new instance of `UsergridAsset`.
    */
    public init(fileName:String? = UsergridAsset.DEFAULT_FILE_NAME, data:NSData, originalLocation:String? = nil, contentType:String) {
        self.fileName = fileName ?? UsergridAsset.DEFAULT_FILE_NAME
        self.assetData = data
        self.originalLocation = originalLocation
        self.contentType = contentType
    }

    /**
    Convenience initializer for `UsergridAsset` objects dealing with image data.

    - parameter fileName:         The file name associated with the file data.
    - parameter image:            The `UIImage` object to upload.
    - parameter imageContentType: The content type of the `UIImage`

    - returns: A new instance of `UsergridAsset` if the data can be gathered from the passed in `UIImage`, otherwise nil.
    */
    public convenience init?(fileName:String? = UsergridAsset.DEFAULT_FILE_NAME, image:UIImage, imageContentType:UsergridImageContentType = .Png) {
        var imageData: NSData?
        switch(imageContentType) {
            case .Png :
                imageData = UIImagePNGRepresentation(image)
            case .Jpeg :
                imageData = UIImageJPEGRepresentation(image, 1.0)
        }
        if let assetData = imageData {
            self.init(fileName:fileName,data:assetData,contentType:imageContentType.stringValue)
        } else {
            return nil
        }
    }

    /**
    Convenience initializer for `UsergridAsset` objects dealing directly with files on disk.

    - parameter fileName:    The file name associated with the file data.
    - parameter fileURL:     The `NSURL` object associated with the file.
    - parameter contentType: The content type of the `UIImage`.  If not specified it will try to figure out the type and if it can't initialization will fail.

    - returns: A new instance of `UsergridAsset` if the data can be gathered from the passed in `NSURL`, otherwise nil.
    */
    public convenience init?(var fileName:String? = UsergridAsset.DEFAULT_FILE_NAME, fileURL:NSURL, var contentType:String? = nil) {
        if fileURL.isFileReferenceURL(), let assetData = NSData(contentsOfURL: fileURL) {
            if fileName != UsergridAsset.DEFAULT_FILE_NAME, let inferredFileName = fileURL.lastPathComponent {
                fileName = inferredFileName
            }
            contentType = contentType ?? UsergridAsset.MIMEType(fileURL)
            if let fileContentType = contentType {
                self.init(fileName:fileName,data:assetData,originalLocation:fileURL.absoluteString,contentType:fileContentType)
            } else {
                print("Usergrid Error: Failed to imply content type of the asset.")
                return nil
            }
        } else {
            return nil
        }
    }

    // MARK: - NSCoding -

    /**
    NSCoding protocol initializer.

    - parameter aDecoder: The decoder.

    - returns: A decoded `UsergridUser` object.
    */
    required public init?(coder aDecoder: NSCoder) {
        guard   let fileName = aDecoder.decodeObjectForKey("fileName") as? String,
                let assetData = aDecoder.decodeObjectForKey("assetData") as? NSData,
                let contentType = aDecoder.decodeObjectForKey("contentType") as? String
        else {
            self.fileName = ""
            self.contentType = ""
            self.originalLocation = nil
            self.assetData = NSData()
            super.init()
            return nil
        }
        self.fileName = fileName
        self.assetData = assetData
        self.contentType = contentType
        self.originalLocation = aDecoder.decodeObjectForKey("originalLocation") as? String
        super.init()
    }

    /**
     NSCoding protocol encoder.

     - parameter aCoder: The encoder.
     */
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.fileName, forKey: "fileName")
        aCoder.encodeObject(self.assetData, forKey: "assetData")
        aCoder.encodeObject(self.contentType, forKey: "contentType")
        aCoder.encodeObject(self.originalLocation, forKey: "originalLocation")
    }

    private static func MIMEType(fileURL: NSURL) -> String? {
        if let pathExtension = fileURL.pathExtension {
            if let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil) {
                let UTI = UTIRef.takeUnretainedValue()
                UTIRef.release()
                if let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType) {
                    let MIMEType = MIMETypeRef.takeUnretainedValue()
                    MIMETypeRef.release()
                    return MIMEType as String
                }
            }
        }
        return nil
    }
}