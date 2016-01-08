//
//  UsergridResponseError.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 1/8/16.
//  Copyright © 2016 Apigee Inc. All rights reserved.
//

import Foundation

/// A standard error object that contains details about a request failure.
public class UsergridResponseError: NSObject {

    /// The error's name.
    public let errorName : String

    /// The error's description.
    public let errorDescription: String

    /// The exception.
    public var exception: String?

    // MARK: - Initialization -

    /**
    Designated initializer for `UsergridResponseError`.

    - parameter errorName:        The error's name.
    - parameter errorDescription: The error's description.
    - parameter exception:        The exception.

    - returns: A new instance of `UsergridResponseError`
    */
    public init(errorName:String, errorDescription:String, exception:String? = nil) {
        self.errorName = errorName
        self.errorDescription = errorDescription
        self.exception = exception
    }

    /**
     Convenience initializer for `UsergridResponseError` that determines if the given `jsonDictionary` contains an error.

     - parameter jsonDictionary: The JSON dictionary that may contain error information.

     - returns: A new instance of `UsergridResponseError` if the JSON dictionary did indeed contain error information.
     */
    public convenience init?(jsonDictionary:[String:AnyObject]) {
        if let errorName = jsonDictionary[USERGRID_ERROR] as? String,
               errorDescription = jsonDictionary[USERGRID_ERROR_DESCRIPTION] as? String {
            self.init(errorName:errorName,errorDescription:errorDescription,exception:jsonDictionary[USERGRID_EXCEPTION] as? String)
        } else {
            return nil
        }
    }
}

let USERGRID_ERROR = "error"
let USERGRID_ERROR_DESCRIPTION = "error_description"
let USERGRID_EXCEPTION = "exception"