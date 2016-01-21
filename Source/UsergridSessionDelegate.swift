//
//  UsergridSessionDelegate.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/30/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

final class UsergridSessionDelegate: NSObject {

    private var requestDelegates: [Int:UsergridAssetRequestWrapper] = [:]

    func addRequestDelegate(task:NSURLSessionTask,requestWrapper:UsergridAssetRequestWrapper) {
        requestDelegates[task.taskIdentifier] = requestWrapper
    }

    func removeRequestDelegate(task:NSURLSessionTask) {
        requestDelegates[task.taskIdentifier] = nil
    }
}

extension UsergridSessionDelegate : NSURLSessionTaskDelegate {

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        if let progressBlock = requestDelegates[task.taskIdentifier]?.progress {
            progressBlock(bytesFinished:totalBytesSent, bytesExpected: totalBytesExpectedToSend)
        }
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if let requestWrapper = requestDelegates[task.taskIdentifier] {
            requestWrapper.error = error
            requestWrapper.completion(requestWrapper: requestWrapper)
        }
        self.removeRequestDelegate(task)
    }
}

extension UsergridSessionDelegate : NSURLSessionDataDelegate {

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if let requestWrapper = requestDelegates[dataTask.taskIdentifier] {
            requestWrapper.response = response
        }
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if let requestWrapper = requestDelegates[dataTask.taskIdentifier] {
            let mutableData = requestWrapper.responseData != nil ? NSMutableData(data: requestWrapper.responseData!) : NSMutableData()
            mutableData.appendData(data)
            requestWrapper.responseData = mutableData
        }
    }
}

extension UsergridSessionDelegate : NSURLSessionDownloadDelegate {

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if let progressBlock = requestDelegates[downloadTask.taskIdentifier]?.progress {
            progressBlock(bytesFinished:totalBytesWritten, bytesExpected: totalBytesExpectedToWrite)
        }
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let requestWrapper = requestDelegates[downloadTask.taskIdentifier] {
            requestWrapper.responseData = NSData(contentsOfURL: location)!
        }
    }
}