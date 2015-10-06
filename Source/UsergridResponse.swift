//
//  UsergridResponse.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 9/2/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public typealias UsergridResponseCompletion = (response: UsergridResponse) -> Void

public class UsergridResponse: NSObject {

    public weak var client: UsergridClient?

    private(set) public var responseJSON: [String:AnyObject]?
    private(set) public var type: String?
    private(set) public var query: UsergridQuery?
    private(set) public var cursor: String?
    private(set) public var entities: [UsergridEntity]?

    private(set) public var headers: [String:String]?
    private(set) public var statusCode: Int?
    private(set) public var metadata: [String:AnyObject]?

    private(set) public var errorName : String?
    private(set) public var errorDescription: String?
    private(set) public var exception: String?

    public var count: Int { return self.entities?.count ?? 0 }

    public var first: UsergridEntity? { return self.entities?.first }
    public var last: UsergridEntity? { return self.entities?.last }
    public var entity: UsergridEntity? { return self.first }

    public var user: UsergridUser? { return self.entities?.first as? UsergridUser }
    public var users: [UsergridUser]? { return self.entities as? [UsergridUser] }

    public var hasNextPage: Bool { return self.cursor != nil }

    public init(client: UsergridClient?, errorName: String? = nil, errorDescription: String? = nil) {
        self.client = client
        self.errorName = errorName
        self.errorDescription = errorDescription
    }

    public init(client:UsergridClient?, type: String?, jsonDict:[String:AnyObject], query: UsergridQuery? = nil){
        self.client = client
        self.type = type
        self.responseJSON = jsonDict

        if let errorName = jsonDict[UsergridResponse.ERROR] as? String {
            self.errorName = errorName
            self.errorDescription = jsonDict[UsergridResponse.ERROR_DESCRIPTION] as? String
            self.exception = jsonDict[UsergridResponse.EXCEPTION] as? String
        } else {
            if let entitiesJSONArray = jsonDict[UsergridResponse.ENTITIES] as? [[String:AnyObject]] where entitiesJSONArray.count > 0 {
                self.entities = UsergridEntity.entities(jsonArray: entitiesJSONArray)
            }
            if let responseQuery = query {
                self.query = responseQuery.copy() as? UsergridQuery
            }
            if let cursor = jsonDict[UsergridResponse.CURSOR] as? String where !cursor.isEmpty {
                self.cursor = cursor
            }
        }
    }

    public func loadNextPage(completion: UsergridResponseCompletion) {
        if self.hasNextPage, let type = self.type {
            if let query = self.query?.copy() as? UsergridQuery {
                self.client?.GET(type, query: query.cursor(self.cursor), completion:completion)
            } else {
                self.client?.GET(type, query: UsergridQuery(self.type).cursor(self.cursor), completion:completion)
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
