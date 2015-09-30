//
//  UsergridRequestManager.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/22/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class UsergridRequestManager : NSObject {

    weak var client: UsergridClient?

    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    public init(client:UsergridClient? = nil) {
        self.client = client
    }

    public static func buildRequestURL(baseURL: String, query: UsergridQuery? = nil, paths: [String]? = nil) -> String {
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

    public static func buildRequest(requestURL:String, _ method:UsergridRequestManager.HttpMethod, _ auth: UsergridAuth? = nil, _ headers: [String:String]? = nil, _ body:NSData? = nil) -> NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string:requestURL)!)
        request.HTTPMethod = method.stringValue
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
            if usergridAuth.tokenIsValid, let accessToken = usergridAuth.accessToken {
                request.setValue("\(UsergridRequestManager.BEARER) \(accessToken)", forHTTPHeaderField: UsergridRequestManager.AUTHORIZATION)
            }
        }
        return request
    }

    public func performRequest(type:String, requestURL:String, method:UsergridRequestManager.HttpMethod, headers: [String:String]? = nil, body: NSData? = nil, completion: UsergridResponseCompletionBlock) {
        performRequest(type, request: UsergridRequestManager.buildRequest(requestURL, method, client?.authForRequests(), headers, body), completion: completion)
    }

    public func performAuthRequest(userAuth userAuth:UsergridUserAuth, request:NSURLRequest, completion:UsergridUserAuthCompletionBlock) {
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
                completion(auth: userAuth, user:user, error: nil)
            } else {
                completion(auth: userAuth, user:nil, error: "Auth Failed")
            }
        }.resume()
    }

    public func performAuthRequest(appAuth appAuth: UsergridAppAuth, request:NSURLRequest, completion: UsergridAppAuthCompletionBlock) {
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            let dataAsJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let jsonDict = dataAsJSON as? [String:AnyObject] {
                if let accessToken = jsonDict[UsergridRequestManager.ACCESS_TOKEN] as? String {
                    appAuth.accessToken = accessToken
                }
                if let expiresIn = jsonDict[UsergridRequestManager.EXPIRES_IN] as? Int {
                    appAuth.expiresIn = expiresIn
                }
                completion(auth: appAuth, error: nil)
            } else {
                completion(auth: appAuth, error: "Auth Failed")
            }
        }.resume()
    }

    public func performRequest(type: String, request: NSURLRequest, completion: UsergridResponseCompletionBlock) {
        session.dataTaskWithRequest(request) { [weak self] (data, response, error) -> Void in
            let dataAsJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            if let jsonDict = dataAsJSON as? [String:AnyObject] {
                let response = UsergridResponse(client: self?.client, type: type, jsonDict: jsonDict)
                completion(response: response)
            } else {
                completion(response: UsergridResponse(client:self?.client, errorName: "", errorDescription: ""))
            }
        }.resume()
    }

    public func performGetAsset(entity:UsergridEntity, contentType:String, completion:UsergridAssetDownloadCompletionBlock) {
        let requestURL = UsergridRequestManager.buildRequestURL(self.client!.clientAppURL, paths: [entity.type,entity.uuidOrName!])
        let request = UsergridRequestManager.buildRequest(requestURL, .GET, self.client?.authForRequests(), ["Accept":contentType], nil)
        session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil, let assetData = data where assetData.length > 0 {
                let asset = UsergridAsset(data: assetData, contentType: contentType)
                completion(asset: asset, error: error?.localizedDescription)
            } else {
                completion(asset: nil, error: error?.localizedDescription)
            }
        }.resume()

    }

    public func performUploadAsset(entity:UsergridEntity, asset:UsergridAsset, completion:UsergridAssetUploadCompletionBlock) {
        let requestURL = UsergridRequestManager.buildRequestURL(self.client!.clientAppURL, paths: [entity.type,entity.uuidOrName!])
        let mulitpartRequestAndBody = asset.multipartRequestAndBody(NSURL(string:requestURL)!)
        session.uploadTaskWithRequest(mulitpartRequestAndBody.request, fromData: mulitpartRequestAndBody.multipartData)
            { (data, response, error) -> Void in
                let dataAsJSON = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                if let jsonDict = dataAsJSON as? [String:AnyObject] {
                    completion(response: UsergridResponse(client: self.client,type:entity.type,jsonDict:jsonDict),asset:asset,error:nil)
                } else {
                    completion(response: UsergridResponse(client: self.client),asset:asset,error:error?.localizedDescription)
                }
        }.resume()
    }

    public func performConnect(type: String, connectedEntity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity) {
//        if let connectedID = connectedEntity.uuid ?? connectedEntity.name, connectingID = connectingEntity.uuid ?? connectingEntity.name {
//
//        }
    }

    public func performDisconnect(type: String, connectedEntity:UsergridEntity, relationship:String, connectingEntity:UsergridEntity) {
//        if let connectedID = connectedEntity.uuid ?? connectedEntity.name, connectingID = connectingEntity.uuid ?? connectingEntity.name {
//
//        }
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

    private static let GET = "GET"
    private static let PUT = "PUT"
    private static let POST = "POST"
    private static let DELETE = "DELETE"

    public enum HttpMethod : Int {
        case GET; case PUT; case POST; case DELETE
        static func fromString(stringValue: String) -> HttpMethod? {
            switch stringValue.lowercaseString {
            case UsergridRequestManager.GET: return .GET
            case UsergridRequestManager.PUT: return .PUT
            case UsergridRequestManager.POST: return .POST
            case UsergridRequestManager.DELETE: return .DELETE
            default: return nil
            }
        }
        var stringValue: String {
            switch self {
            case .GET: return UsergridRequestManager.GET
            case .PUT: return UsergridRequestManager.PUT
            case .POST: return UsergridRequestManager.POST
            case .DELETE: return UsergridRequestManager.DELETE
            }
        }
    }
}