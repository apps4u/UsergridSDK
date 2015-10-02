//
//  UsergridRequest.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 10/1/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation

typealias UsergridAssetRequestWrapperCompletionBlock = (requestWrapper:UsergridAssetRequestWrapper) -> Void

final class UsergridAssetRequestWrapper {
    weak var session: NSURLSession?
    let sessionTask: NSURLSessionTask

    var response: NSURLResponse?
    var responseData: NSData?
    var error: NSError?

    var progress: UsergridAssetRequestProgressBlock?
    let completion: UsergridAssetRequestWrapperCompletionBlock

    init(session:NSURLSession?, sessionTask:NSURLSessionTask, progress:UsergridAssetRequestProgressBlock?, completion:UsergridAssetRequestWrapperCompletionBlock) {
        self.session = session
        self.sessionTask = sessionTask
        self.progress = progress
        self.completion = completion
    }
}