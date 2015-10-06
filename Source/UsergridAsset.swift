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

public class UsergridAsset: NSObject {

    private static let DEFAULT_FILE_NAME = "file"

    public let fileName: String
    public let assetData: NSData

    public let originalLocation: String?
    public var contentType: String

    public var contentLength: Int { return self.assetData.length }

    public init(fileName:String? = UsergridAsset.DEFAULT_FILE_NAME, data:NSData, originalLocation:String? = nil, contentType:String) {
        self.fileName = fileName ?? UsergridAsset.DEFAULT_FILE_NAME
        self.assetData = data
        self.originalLocation = originalLocation
        self.contentType = contentType
    }

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

//MARK: - MultiPart Creation -
extension UsergridAsset {

    private static let ASSET_UPLOAD_BOUNDARY = "apigee-asset-upload-boundary"
    private static let ASSET_UPLOAD_CONTENT_HEADER = "multipart/form-data; boundary=\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)"
    private static let CONTENT_DISPOSITION = "Content-Disposition"
    private static let MULTIPART_START = "--\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)\r\n"
    private static let MULTIPART_END = "\r\n--\(UsergridAsset.ASSET_UPLOAD_BOUNDARY)--\r\n" as NSString
    private static let FORM_DATA = "form-data"

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

    public func multipartRequest(requestURL:NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: requestURL)
        request.HTTPMethod = UsergridHttpMethod.PUT.rawValue
        request.setValue(UsergridAsset.ASSET_UPLOAD_CONTENT_HEADER, forHTTPHeaderField: UsergridRequestManager.CONTENT_TYPE)
        request.setValue(String(format: "%lu", self.multiPartHTTPBody.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)
        return request
    }

    public func multipartRequestAndBody(requestURL:NSURL) -> (request:NSMutableURLRequest,multipartData:NSData) {
        return (self.multipartRequest(requestURL),self.multiPartHTTPBody)
    }
}