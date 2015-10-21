//
//  UsergridRequestManager.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/22/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

enum UsergridHttpMethod : String {
    case GET
    case PUT
    case POST
    case DELETE
}

final class UsergridRequestManager {

    unowned let client: UsergridClient

    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                delegate:UsergridSessionDelegate(),
                                delegateQueue:NSOperationQueue.mainQueue())

    var sessionDelegate : UsergridSessionDelegate {
        return session.delegate as! UsergridSessionDelegate
    }

    init(client:UsergridClient) {
        self.client = client
    }

    deinit {
        session.invalidateAndCancel()
    }

    static func buildRequestURL(baseURL: String, query: UsergridQuery? = nil, paths: [String]? = nil) -> String {
        var constructedURLString = baseURL
        if let appendingPaths = paths {
            for pathToAppend in appendingPaths {
                constructedURLString = "\(constructedURLString)\(UsergridRequestManager.FORWARD_SLASH)\(pathToAppend)"
            }
        }
        if let queryToAppend = query {
            let appendFromQuery = queryToAppend.build()
            if !appendFromQuery.isEmpty {
                constructedURLString = "\(constructedURLString)\(UsergridRequestManager.FORWARD_SLASH)\(appendFromQuery)"
            }
        }
        return constructedURLString
    }

    static func buildRequest(requestURL:String, _ method:UsergridHttpMethod, _ auth: UsergridAuth? = nil, _ headers: [String:String]? = nil, _ body:NSData? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string:requestURL)!)
        request.HTTPMethod = method.rawValue
        if let httpHeaders = headers {
            for (key,value) in httpHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let httpBody = body {
            request.HTTPBody = httpBody
            request.setValue(String(format: "%lu", httpBody.length), forHTTPHeaderField: UsergridRequestManager.CONTENT_LENGTH)
        }

        if let usergridAuth = auth {
            UsergridRequestManager.applyAuth(usergridAuth, request: request)
        }
        return request
    }

    func performRequest(type:String, requestURL:String, method:UsergridHttpMethod, headers: [String:String]? = nil, body: NSData? = nil, completion: UsergridResponseCompletion?) {
        performRequest(type, request: UsergridRequestManager.buildRequest(requestURL, method, client.authForRequests(), headers, body), completion: completion)
    }

    func performRequest(type: String, request: NSURLRequest, completion: UsergridResponseCompletion?) {
        session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            completion?(response: UsergridResponse(client:self?.client, data: data, response: response as? NSHTTPURLResponse, error: error))
        }.resume()
    }

    static let AUTHORIZATION = "Authorization"
    static let ACCESS_TOKEN = "access_token"
    static let BEARER = "Bearer"
    static let CONTENT_TYPE = "Content-Type"
    static let CONTENT_LENGTH = "Content-Length"
    static let EXPIRES_IN = "expires_in"
    static let FORWARD_SLASH = "/"
    static let APPLICATION_JSON = "application/json"

    static let JSON_CONTENT_TYPE_HEADER = [UsergridRequestManager.CONTENT_TYPE:UsergridRequestManager.APPLICATION_JSON]
}


// MARK: - Authentication -
extension UsergridRequestManager {

    static func applyAuth(auth:UsergridAuth,request:NSMutableURLRequest) {
        if auth.tokenIsValid, let accessToken = auth.accessToken {
            request.setValue("\(UsergridRequestManager.BEARER) \(accessToken)", forHTTPHeaderField: UsergridRequestManager.AUTHORIZATION)
        }
    }

    func performLogoutUserRequest(uuidOrUsername uuidOrUsername:String, token:String? = nil, completion:UsergridResponseCompletion?) {
        var paths = ["users",uuidOrUsername]
        if let accessToken = token {
            paths.append("revoketoken?token=\(accessToken)")
        } else {
            paths.append("revoketokens")
        }
        let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths:paths)
        let request = UsergridRequestManager.buildRequest(requestURL, .PUT, self.client.authForRequests())
        session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            completion?(response:UsergridResponse(client:self?.client, data:data, response:response as? NSHTTPURLResponse, error: error, query: nil))
        }.resume()
    }

    func performAuthRequest(userAuth userAuth:UsergridUserAuth, request:NSURLRequest, completion:UsergridUserAuthCompletionBlock?) {
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let dataAsJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let jsonDict = dataAsJSON as? [String:AnyObject] {
                if let accessToken = jsonDict[UsergridRequestManager.ACCESS_TOKEN] as? String {
                    userAuth.accessToken = accessToken
                }
                if let expiresIn = jsonDict[UsergridRequestManager.EXPIRES_IN] as? Int {
                    userAuth.expiresIn = expiresIn
                }
                var user: UsergridUser?
                if let userDict = jsonDict[UsergridUser.USER_ENTITY_TYPE] as? [String:AnyObject] {
                    if let createdUser = UsergridEntity.entity(jsonDict: userDict) as? UsergridUser {
                        createdUser.auth = userAuth
                        user = createdUser
                    }
                }
                completion?(auth: userAuth, user:user, error: nil)
            } else {
                completion?(auth: userAuth, user:nil, error: "Auth Failed. Error Description: \(error?.localizedDescription).")
            }
        }.resume()
    }

    func performAuthRequest(appAuth appAuth: UsergridAppAuth, request:NSURLRequest, completion: UsergridAppAuthCompletionBlock?) {
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let dataAsJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let jsonDict = dataAsJSON as? [String:AnyObject] {
                if let accessToken = jsonDict[UsergridRequestManager.ACCESS_TOKEN] as? String {
                    appAuth.accessToken = accessToken
                }
                if let expiresIn = jsonDict[UsergridRequestManager.EXPIRES_IN] as? Int {
                    appAuth.expiresIn = expiresIn
                }
                completion?(auth: appAuth, error: nil)
            } else {
                completion?(auth: nil, error: "Auth Failed. Error Description: \(error?.localizedDescription).")
            }
        }.resume()
    }
}

// MARK: - Entity Connections -
extension UsergridRequestManager {

    func performConnect(connectedEntity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity, completion: UsergridResponseCompletion?) {
        if let connectedID = connectedEntity.uuidOrName, connectingID = connectingEntity.uuidOrName {
            let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths: [connectedEntity.type,connectedID,relationship,connectingEntity.type,connectingID])
            let request = UsergridRequestManager.buildRequest(requestURL, .POST, self.client.authForRequests())
            session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
                completion?(response:UsergridResponse(client:self?.client, data:data, response:response as? NSHTTPURLResponse, error: error, query: nil))
            }.resume()
        } else {
            completion?(response: UsergridResponse(client: self.client, errorName: "Invalid Entity Connection Attempt.", errorDescription: "One or both entities that are attempting to be connected do not contain a valid UUID or Name property."))
        }
    }

    func performDisconnect(connectedEntity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity,completion: UsergridResponseCompletion?) {
        if let connectedID = connectedEntity.uuidOrName, connectingID = connectingEntity.uuidOrName {
            let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths: [connectedEntity.type,connectedID,relationship,connectingEntity.type,connectingID])
            let request = UsergridRequestManager.buildRequest(requestURL, .DELETE, self.client.authForRequests())
            session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
                completion?(response:UsergridResponse(client:self?.client, data:data, response:response as? NSHTTPURLResponse, error: error, query: nil))
            }.resume()
        } else {
            completion?(response: UsergridResponse(client: self.client, errorName: "Invalid Entity Disconnect Attempt.", errorDescription: "The connecting and connected entities must have a `uuid` or `name` assigned."))
        }
    }

    func getConnectedEntities(entity:UsergridEntity, relationship:String, completion:UsergridResponseCompletion?) {
        if let entityID = entity.uuidOrName {
            let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths: [entity.type,entityID,relationship])
            let request = UsergridRequestManager.buildRequest(requestURL, .DELETE, self.client.authForRequests())
            session.dataTaskWithRequest(request) { [weak self] (data,response,error) in
                completion?(response:UsergridResponse(client:self?.client, data:data, response:response as? NSHTTPURLResponse, error: error, query: nil))
            }.resume()
        }
    }
}

// MARK: - Asset Management -
extension UsergridRequestManager {

    func performGetAsset(entity:UsergridEntity, contentType:String, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetDownloadCompletion?) {
        let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths: [entity.type,entity.uuidOrName!])
        let request = UsergridRequestManager.buildRequest(requestURL, .GET, self.client.authForRequests(), ["Accept":contentType], nil)
        let downloadTask = session.downloadTaskWithRequest(request)
        let requestWrapper = UsergridAssetRequestWrapper(session: self.session, sessionTask: downloadTask, progress: progress)  { (request) -> Void in
            if let assetData = request.responseData where assetData.length > 0 {
                let asset = UsergridAsset(data: assetData, contentType: contentType)
                entity.asset = asset
                completion?(asset: asset, error:nil)
            } else {
                completion?(asset: nil, error: "Downloading asset failed.  No data was recieved.")
            }
        }
        self.sessionDelegate.addRequestDelegate(requestWrapper.sessionTask, requestWrapper:requestWrapper)
        requestWrapper.sessionTask.resume()
    }

    func performUploadAsset(entity:UsergridEntity, asset:UsergridAsset, progress:UsergridAssetRequestProgress? = nil, completion:UsergridAssetUploadCompletion?) {
        let requestURL = UsergridRequestManager.buildRequestURL(self.client.clientAppURL, paths: [entity.type,entity.uuidOrName!])
        let mulitpartRequestAndBody = asset.multipartRequestAndBody(NSURL(string:requestURL)!)
        if let usergridAuth = self.client.authForRequests() {
            UsergridRequestManager.applyAuth(usergridAuth, request: mulitpartRequestAndBody.request)
        }
        let uploadTask = session.uploadTaskWithRequest(mulitpartRequestAndBody.request, fromData: mulitpartRequestAndBody.multipartData)

        let requestWrapper = UsergridAssetRequestWrapper(session: self.session, sessionTask: uploadTask, progress: progress)  { (request) -> Void in
            completion?(response: UsergridResponse(client: self.client, data: request.responseData, response: request.response as? NSHTTPURLResponse, error: request.error),asset:asset,error:nil)
        }
        self.sessionDelegate.addRequestDelegate(requestWrapper.sessionTask, requestWrapper:requestWrapper)
        requestWrapper.sessionTask.resume()
    }
}