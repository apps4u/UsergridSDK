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
`UsergridResponse` is the core class that handles both successful and unsuccessful HTTP responses from Usergrid. 

If a request is successful, any entities returned in the response will be automatically parsed into `UsergridEntity` objects and pushed to the `entities` property.

If a request fails, the `errorName` and `errorDescription` will contain information about the problem encountered.
*/
public class UsergridResponse: NSObject {

    // MARK: - Instance Properties -

    /// The client that was responsible for the request.
    public weak var client: UsergridClient?

    /// The raw response JSON.
    internal(set) public var responseJSON: [String:AnyObject]?

    /// The query used on the request.
    internal(set) public var query: UsergridQuery?

    /// The cursor from the response.
    internal(set) public var cursor: String?

    /// The entities created from the response JSON.
    internal(set) public var entities: [UsergridEntity]?

    /// The response headers.
    internal(set) public var headers: [String:String]?

    /// The response status code.
    internal(set) public var statusCode: Int?

    /// The error object containing error information if one occurred.
    internal(set) public var error: UsergridResponseError?

    /// The count of `entities`.
    public var count: Int { return self.entities?.count ?? 0 }

    /// The first entity in `entities`.
    public var first: UsergridEntity? { return self.entities?.first }

    /// The last entity in `entities`.
    public var last: UsergridEntity? { return self.entities?.last }

    /// The first entity in `entities`.
    public var entity: UsergridEntity? { return self.first }

    /// The `UsergridUser` entity.
    public var user: UsergridUser? { return self.entities?.first as? UsergridUser }

    /// An array of `UsergridUser` entities.
    public var users: [UsergridUser]? { return self.entities as? [UsergridUser] }

    /// Does the response have a cursor.
    public var hasNextPage: Bool { return self.cursor != nil }

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridResponse` objects that contain errors.
    
    These types of responses are usually created because request conditions are not met.

    - parameter client:           The client responsible for the request.
    - parameter errorName:        The error name.
    - parameter errorDescription: The error description.

    - returns: A new instance of `UsergridResponse`.
    */
    public init(client: UsergridClient?, errorName: String, errorDescription: String) {
        self.client = client
        self.error = UsergridResponseError(errorName: errorName, errorDescription: errorDescription, exception: nil)
    }

    /**
    Designated initializer for `UsergridResponse` objects finished but still may contain errors.

    - parameter client:   The client responsible for the request.
    - parameter data:     The response data.
    - parameter response: The `NSHTTPURLResponse` object.
    - parameter error:    The `NSError` object.
    - parameter query:    The query when making the request.

    - returns: A new instance of `UsergridResponse`.
    */
    public init(client:UsergridClient?, data:NSData?, response:NSHTTPURLResponse?, error:NSError?, query:UsergridQuery? = nil) {
        self.client = client
        self.statusCode = response?.statusCode
        self.headers = response?.allHeaderFields as? [String:String]

        if let sessionError = error {
            self.error = UsergridResponseError(errorName: sessionError.domain, errorDescription: sessionError.localizedDescription)
        }

        if let responseQuery = query {
            self.query = responseQuery.copy() as? UsergridQuery
        }

        if let jsonData = data {
            do {
                let dataAsJSON = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                if let jsonDict = dataAsJSON as? [String:AnyObject] {
                    self.responseJSON = jsonDict
                    if let responseError = UsergridResponseError(jsonDictionary: jsonDict) {
                        self.error = responseError
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

    // MARK: - Instance Methods -

    /**
    Attempts to load the next page of `UsergridEntity` objects. 
    
    This requires a `cursor` to be valid as well as a `path` key within the response JSON.

    - parameter completion: The completion block that is called once the request for the next page has finished.
    */
    public func loadNextPage(completion: UsergridResponseCompletion) {
        if self.hasNextPage, let type = (self.responseJSON?["path"] as? NSString)?.lastPathComponent {
            if let query = self.query?.copy() as? UsergridQuery {
                self.client?.GET(type, query: query.cursor(self.cursor), completion:completion)
            } else {
                self.client?.GET(type, query: UsergridQuery(type).cursor(self.cursor), completion:completion)
            }
        } else {
            completion(response: UsergridResponse(client: self.client, errorName: "No next page.", errorDescription: "No next page was found."))
        }
    }

    static let CURSOR = "cursor"
    static let ENTITIES = "entities"
}
