//
//  UsergridResponse.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/2/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

/// The completion block used in for most `UsergridClient` requests.
public typealias UsergridResponseCompletion = (response: UsergridResponse) -> Void

/**

*/
public class UsergridResponse: NSObject {

    public weak var client: UsergridClient?

    ///
    internal(set) public var responseJSON: [String:AnyObject]?

    ///
    internal(set) public var query: UsergridQuery?

    ///
    internal(set) public var cursor: String?

    ///
    internal(set) public var entities: [UsergridEntity]?

    ///
    internal(set) public var headers: [String:String]?

    ///
    internal(set) public var statusCode: Int?

    ///
    internal(set) public var errorName : String?

    ///
    internal(set) public var errorDescription: String?

    ///
    internal(set) public var exception: String?

    ///
    public var count: Int { return self.entities?.count ?? 0 }

    ///
    public var first: UsergridEntity? { return self.entities?.first }

    ///
    public var last: UsergridEntity? { return self.entities?.last }

    ///
    public var entity: UsergridEntity? { return self.first }

    ///
    public var user: UsergridUser? { return self.entities?.first as? UsergridUser }

    ///
    public var users: [UsergridUser]? { return self.entities as? [UsergridUser] }

    ///
    public var hasNextPage: Bool { return self.cursor != nil }

    /**


    - parameter client:           The client.
    - parameter errorName:        The error name.
    - parameter errorDescription: The error description.

    - returns: A new instance of `UsergridResponse`.
    */
    public init(client: UsergridClient?, errorName: String? = nil, errorDescription: String? = nil) {
        self.client = client
        self.errorName = errorName
        self.errorDescription = errorDescription
    }

    public init(client:UsergridClient?, data:NSData?, response:NSHTTPURLResponse?, error:NSError?, query:UsergridQuery? = nil) {
        self.client = client

        self.statusCode = response?.statusCode
        self.headers = response?.allHeaderFields as? [String:String]

        self.errorName = error?.domain
        self.errorDescription = error?.localizedDescription

        if let responseQuery = query {
            self.query = responseQuery.copy() as? UsergridQuery
        }

        if let jsonData = data {
            do {
                let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                if let jsonDict = dataAsJSON as? [String:AnyObject] {
                    self.responseJSON = jsonDict
                    if let errorName = jsonDict[UsergridResponse.ERROR] as? String {
                        self.errorName = errorName
                        self.errorDescription = jsonDict[UsergridResponse.ERROR_DESCRIPTION] as? String
                        self.exception = jsonDict[UsergridResponse.EXCEPTION] as? String
                    } else {
                        if let entitiesJSONArray = jsonDict[UsergridResponse.ENTITIES] as? [[String:AnyObject]] where entitiesJSONArray.count > 0 {
                            self.entities = UsergridEntity.entities(jsonArray: entitiesJSONArray)
                        }
                        if let cursor = jsonDict[UsergridResponse.CURSOR] as? String where !cursor.isEmpty {
                            self.cursor = cursor
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }

    public func loadNextPage(completion: UsergridResponseCompletion) {
        if self.hasNextPage, let type = (self.responseJSON?["path"] as? NSString)?.lastPathComponent {
            if let query = self.query?.copy() as? UsergridQuery {
                self.client?.GET(type, query: query.cursor(self.cursor), completion:completion)
            } else {
                self.client?.GET(type, query: UsergridQuery(type).cursor(self.cursor), completion:completion)
            }
        } else {
            completion(response: UsergridResponse(client: self.client, errorName: "", errorDescription: ""))
        }
    }

    static let CURSOR = "cursor"
    static let ENTITIES = "entities"
    static let ERROR = "error"
    static let ERROR_DESCRIPTION = "error_description"
    static let EXCEPTION = "exception"
}
