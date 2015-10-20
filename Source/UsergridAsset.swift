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

public typealias UsergridAssetRequestProgress = (bytesFinished:Int64, bytesExpected: Int64) -> Void
public typealias UsergridAssetUploadCompletion = (response:UsergridResponse,asset:UsergridAsset?, error: String?) -> Void
public typealias UsergridAssetDownloadCompletion = (asset:UsergridAsset?, error: String?) -> Void

@objc public enum UsergridImageContentType : Int {
    case Png
    case Jpeg
    public var stringValue: String {
        switch self {
            case .Png: return "image/png"
            case .Jpeg: return "image/jpeg"
        }
    }
}

/// A container for assets which are connected to `UsergridEntity` objects.
public class UsergridAsset: NSObject {

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

    private static let DEFAULT_FILE_NAME = "file"

    // MARK: - Instance Properties -

    /// The assets file name.
    public let fileName: String

    /// The assets file data.
    public let assetData: NSData

    /// The original location of the data.
    public let originalLocation: String?

    /// The content type of the asset.
    public var contentType: String

    ///  The content length of the assets data.
    public var contentLength: Int { return self.assetData.length }

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

    private static let ASSET_UPLOAD_BOUNDARY = "apigee-asset-upload-boundary"
    private static let ASSET_UPLOAD_CONTENT_HEADER = "multipart/form-data; boundary=\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)"
    private static let CONTENT_DISPOSITION = "Content-Disposition"
    private static let MULTIPART_START = "--\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)\r\n"
    private static let MULTIPART_END = "\r\n--\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)--\r\n" as NSString
    private static let FORM_DATA = "form-data"

    //MARK: - MultiPart Creation -

    /// A constructed multipart http body for requests to upload.
    public var multiPartHTTPBody: NSData {
        let httpBodyString = UsergridAsset.MULTIPART_START +
            "\(UsergridAsset.CONTENT_DISPOSITION):\(UsergridAsset.FORM_DATA); name=file; filename=\(self.fileName)\r\n" +
            "\(UsergridRequestManager.CONTENT_TYPE): \(self.contentType)\r\n\r\n" as NSString

        let assetBodyData = self.assetData

        let httpBody = NSMutableData()
        httpBody.appendData(httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody.appendData(assetBodyData)
        httpBody.appendData(UsergridAsset.MULTIPART_END.dataUsingEncoding(NSUTF8StringEncoding)!)

        return httpBody
    }

    /**
    Generates a `NSMutableURLRequest` object based on the passed in requestURL and the assets current properties.

    - parameter requestURL: The requests URL.

    - returns: The created `NSMutableURLRequest` object.
    */
    public func multipartRequest(requestURL:NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = UsergridHttpMethod.PUT.rawValue
        request.setValue(UsergridAsset.ASSET_UPLOAD_CONTENT_HEADER, forHTTPHeaderField: UsergridRequestManager.CONTENT_TYPE)
        request.setValue(String(format: "%lu", self.multiPartHTTPBody.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)
        return request
    }

    /**
    Creates and returns both the `NSMutableURLRequest` object as well as the multiPartHTTPBody in a tuple.

    - parameter requestURL: The requests URL.

    - returns: The tuple containing the request and httpBody.
    */
    public func multipartRequestAndBody(requestURL:NSURL) -> (request:NSMutableURLRequest,multipartData:NSData) {
        return (self.multipartRequest(requestURL),self.multiPartHTTPBody)
    }
}