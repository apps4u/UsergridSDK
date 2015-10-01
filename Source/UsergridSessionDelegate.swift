//
//  UsergridSessionDelegate.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/30/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

public protocol UsergridProgessDelegate {
    func progress(currentBytes:Int64,totalBytesExpected:Int64)
}

class UsergridUploadWrapper {
    var uploadTask: NSURLSessionUploadTask?
}

final class UsergridSessionDelegate: NSObject, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {

    private var uploadAssetDelegateCompletions: [Int:(UsergridAssetProgressBlock,UsergridUploadWrapper)] = [:]
    private var downloadAssetDelegateCompletions: [Int:(UsergridAssetProgressBlock?,UsergridAssetDownloadCompletionBlock)] = [:]

    func addUploadProgressCompletion(task:NSURLSessionTask,progressBlockAndWrapper:(UsergridAssetProgressBlock,UsergridUploadWrapper)) {
        self.uploadAssetDelegateCompletions[task.taskIdentifier] = progressBlockAndWrapper
    }

    func removeUploadProgressCompletion(task:NSURLSessionTask) {
        self.uploadAssetDelegateCompletions.removeValueForKey(task.taskIdentifier)
    }

    func addDownloadProgressCompletion(task:NSURLSessionTask,progressAndCompletionBlock:(UsergridAssetProgressBlock?,UsergridAssetDownloadCompletionBlock)) {
        self.downloadAssetDelegateCompletions[task.taskIdentifier] = progressAndCompletionBlock
    }

    func removeDownloadProgressCompletion(task:NSURLSessionTask) {
        self.downloadAssetDelegateCompletions.removeValueForKey(task.taskIdentifier)
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let progressBlock = self.downloadAssetDelegateCompletions[downloadTask.taskIdentifier]?.0 {
            progressBlock(bytesFinished:totalBytesWritten, bytesExpected: totalBytesExpectedToWrite)
        }
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let completion = self.downloadAssetDelegateCompletions[downloadTask.taskIdentifier]?.1 {
            if let assetData = NSData(contentsOfURL: location) where assetData.length > 0 {
                let asset = UsergridAsset(data: assetData, contentType: "") // Content type will be
                completion(asset: asset, error:nil)
            } else {
                completion(asset: nil, error: "Downloading asset Failed.  No data was recieved.")
            }
        }
        self.removeDownloadProgressCompletion(downloadTask)
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let progressBlock = self.uploadAssetDelegateCompletions[task.taskIdentifier]?.0 {
            progressBlock(bytesFinished:totalBytesSent, bytesExpected: totalBytesExpectedToSend)
        }
    }
}