//
//  UsergridQuery.swift
//  UsergridSDK
//
//  Created by Robert Walsh on 7/22/15.
//  Copyright © 2015 Apigee. All rights reserved.
//

import Foundation

public class UsergridQuery : NSObject,NSCopying {

    public init(_ collectionName: String? = nil) {
        self.collectionName = collectionName
    }

    public func copyWithZone(zone: NSZone) -> AnyObject {
        let queryCopy = UsergridQuery(self.collectionName)
        queryCopy.requirementStrings = NSArray(array:self.requirementStrings, copyItems: true) as! [String]
        queryCopy.urlTerms = NSArray(array:self.urlTerms, copyItems: true) as! [String]
        for (key,value) in self.orderClauses {
            queryCopy.orderClauses[key] = value
        }
        queryCopy.limit = self.limit
        queryCopy.cursor = self.cursor
        return queryCopy
    }

    public func build(autoURLEncode: Bool = true) -> String {
        return self.constructURLAppend(autoURLEncode)
    }

    public func containsString(term: String, value: String) -> Self { return self.containsWord(term, value: value) }
    public func containsWord(term: String, value: String) -> Self { return self.addRequirement(term + UsergridQuery.SPACE + UsergridQuery.CONTAINS + UsergridQuery.SPACE + UsergridQuery.APOSTROPHE + value + UsergridQuery.APOSTROPHE) }

    public func ascending(term: String) -> Self { return self.asc(term) }
    public func asc(term: String) -> Self { return self.sort(term, sortOrder: QuerySortOrder.Asc) }

    public func descending(term: String) -> Self { return self.desc(term) }
    public func desc(term: String) -> Self { return self.sort(term, sortOrder: QuerySortOrder.Desc) }

    public func filter(term: String, value: AnyObject) -> Self { return self.eq(term, value: value) }
    public func equals(term: String, value: AnyObject) -> Self { return self.eq(term, value: value) }
    public func eq(term: String, value: AnyObject) -> Self { return self.addOperationRequirement(term, operation:.Equal, value: value) }

    public func greaterThan(term: String, value: AnyObject) -> Self { return self.gt(term, value: value) }
    public func gt(term: String, value: AnyObject) -> Self { return self.addOperationRequirement(term, operation:.GreaterThan, value: value) }

    public func greaterThanOrEqual(term: String, value: AnyObject) -> Self { return self.gte(term, value: value) }
    public func gte(term: String, value: AnyObject) -> Self { return self.addOperationRequirement(term, operation:.GreaterThanEqualTo, value: value) }

    public func lessThan(term: String, value: AnyObject) -> Self { return self.lt(term, value: value) }
    public func lt(term: String, value: AnyObject) -> Self { return self.addOperationRequirement(term, operation:.LessThan, value: value) }

    public func lessThanOrEqual(term: String, value: AnyObject) -> Self { return self.lte(term, value: value) }
    public func lte(term: String, value: AnyObject) -> Self { return self.addOperationRequirement(term, operation:.LessThanEqualTo, value: value) }

    public func withinLocation(distance: Float, latitude: Float, longitude: Float) -> Self {
        return self.addRequirement(UsergridQuery.LOCATION + UsergridQuery.SPACE + UsergridQuery.WITHIN + UsergridQuery.SPACE + distance.description + UsergridQuery.SPACE + UsergridQuery.OF + UsergridQuery.SPACE + latitude.description + UsergridQuery.COMMA + longitude.description )
    }

    public func or() -> Self {
        if !self.requirementStrings.first!.isEmpty {
            self.requirementStrings.insert(UsergridQuery.EMPTY_STRING, atIndex: 0)
        }
        return self
    }

    public func sort(term: String, sortOrder: QuerySortOrder) -> Self {
        self.orderClauses[term] = sortOrder
        return self
    }

    public func collection(collectionName: String) -> Self {
        self.collectionName = collectionName
        return self
    }

    public func limit(limit: Int) -> Self {
        self.limit = limit
        return self
    }

    public func ql(value: String) -> Self {
        return self.addRequirement(value)
    }

    public func cursor(value: String?) -> Self {
        self.cursor = value
        return self
    }

    public func urlTerm(term: String, equalsValue: String) -> Self {
        if (term as NSString).isEqualToString(UsergridQuery.QL) {
            self.ql(equalsValue)
        } else {
            self.urlTerms.append(term + QueryOperator.Equal.stringValue + equalsValue)
        }
        return self
    }

    public func addOperationRequirement(term: String, operation: QueryOperator, stringValue: String) -> Self {
        return self.addOperationRequirement(term,operation:operation,value:stringValue)
    }

    public func addOperationRequirement(term: String, operation: QueryOperator, intValue: Int) -> Self {
        return self.addOperationRequirement(term,operation:operation,value:intValue)
    }

    private func addRequirement(requirement: String) -> Self {
        var requirementString: String = self.requirementStrings.removeAtIndex(0)
        if !requirementString.isEmpty {
            requirementString += UsergridQuery.SPACE + UsergridQuery.AND + UsergridQuery.SPACE
        }
        requirementString += requirement
        self.requirementStrings.insert(requirementString, atIndex: 0)
        return self
    }

    private func addOperationRequirement(term: String, operation: QueryOperator, value: AnyObject) -> Self {
        if value is String {
            return self.addRequirement(term + UsergridQuery.SPACE + operation.stringValue + UsergridQuery.SPACE + UsergridQuery.APOSTROPHE + value.description + UsergridQuery.APOSTROPHE )
        } else {
            return self.addRequirement(term + UsergridQuery.SPACE + operation.stringValue + UsergridQuery.SPACE + value.description)
        }
    }

    private func constructOrderByString() -> String {
        var orderByString = UsergridQuery.EMPTY_STRING
        if !self.orderClauses.isEmpty {
            var combinedClausesArray: [String] = []
            for (key,value) in self.orderClauses {
                combinedClausesArray.append(key + UsergridQuery.SPACE + value.stringValue)
            }
            for index in 0..<combinedClausesArray.count {
                if index > 0 {
                    orderByString += UsergridQuery.COMMA
                }
                orderByString += combinedClausesArray[index]
            }
            if !orderByString.isEmpty {
                orderByString = UsergridQuery.SPACE + UsergridQuery.ORDER_BY + UsergridQuery.SPACE + orderByString
            }
        }
        return orderByString
    }

    private func constructURLTermsString() -> String {
        return (self.urlTerms as NSArray).componentsJoinedByString(UsergridQuery.AMPERSAND)
    }

    private func constructRequirementString() -> String {
        var requirementsString = UsergridQuery.EMPTY_STRING
        var requirementStrings = self.requirementStrings
        if requirementStrings.first!.isEmpty {
            requirementStrings.removeAtIndex(0)
            requirementsString = (requirementStrings.reverse() as NSArray).componentsJoinedByString(" \(UsergridQuery.OR) ")
        } else {
            requirementsString = (requirementStrings.reverse() as NSArray).componentsJoinedByString(" \(UsergridQuery.OR) ")
        }
        return requirementsString
    }

    private func constructURLAppend(autoURLEncode: Bool = true) -> String {
        var urlAppend = UsergridQuery.EMPTY_STRING
        if self.limit != UsergridQuery.LIMIT_DEFAULT {
            urlAppend += "\(UsergridQuery.LIMIT)=\(self.limit.description)"
        }
        let urlTermsString = self.constructURLTermsString()
        if !urlTermsString.isEmpty {
            if !urlAppend.isEmpty {
                urlAppend += UsergridQuery.AMPERSAND
            }
            urlAppend += urlTermsString
        }
        if let cursorString = self.cursor where !cursorString.isEmpty {
            if !urlAppend.isEmpty {
                urlAppend += UsergridQuery.AMPERSAND
            }
            urlAppend += "\(UsergridQuery.CURSOR)=\(cursorString)"
        }

        var requirementsString = self.constructRequirementString()
        let orderByString = self.constructOrderByString()
        if !orderByString.isEmpty {
            requirementsString += orderByString
        }
        if !requirementsString.isEmpty {
            if autoURLEncode {
                if let encodedRequirementsString = requirementsString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
                    requirementsString = encodedRequirementsString
                }
            }
            if !urlAppend.isEmpty {
                urlAppend += UsergridQuery.AMPERSAND
            }
            urlAppend += "\(UsergridQuery.QL)=\(requirementsString)"
        }

        if !urlAppend.isEmpty {
            urlAppend = "\(UsergridQuery.QUESTION_MARK)\(urlAppend)"
        }
        return urlAppend
    }

    private(set) var collectionName: String? = nil
    private(set) var cursor: String? = nil
    private(set) var limit: Int = UsergridQuery.LIMIT_DEFAULT

    private(set) var requirementStrings: [String] = [UsergridQuery.EMPTY_STRING]
    private(set) var orderClauses: [String:QuerySortOrder] = [:]
    private(set) var urlTerms: [String] = []

    private static let LIMIT_DEFAULT = 10
    private static let AMPERSAND = "&"
    private static let AND = "and"
    private static let APOSTROPHE = "'"
    private static let COMMA = ","
    private static let CONTAINS = "contains"
    private static let CURSOR = "cursor"
    private static let EMPTY_STRING = ""
    private static let IN = "in"
    private static let LIMIT = "limit"
    private static let LOCATION = "location";
    private static let OF = "of"
    private static let OR = "or"
    private static let ORDER_BY = "order by"
    private static let QL = "ql"
    private static let QUESTION_MARK = "?"
    private static let SPACE = " "
    private static let WITHIN = "within"

    private static let ASC = "asc"
    private static let DESC = "desc"
    private static let EQUAL = "="
    private static let GREATER_THAN = ">"
    private static let GREATER_THAN_EQUAL_TO = ">="
    private static let LESS_THAN = "<"
    private static let LESS_THAN_EQUAL_TO = "<="

    @objc public enum QueryOperator: Int {
        case Equal; case GreaterThan; case GreaterThanEqualTo; case LessThan; case LessThanEqualTo
        static func fromString(stringValue: String) -> QueryOperator? {
            switch stringValue.lowercaseString {
                case UsergridQuery.EQUAL: return .Equal
                case UsergridQuery.GREATER_THAN: return .GreaterThan
                case UsergridQuery.GREATER_THAN_EQUAL_TO: return .GreaterThanEqualTo
                case UsergridQuery.LESS_THAN: return .LessThan
                case UsergridQuery.LESS_THAN_EQUAL_TO: return .LessThanEqualTo
                default: return nil
            }
        }
        var stringValue: String {
            switch self {
                case .Equal: return UsergridQuery.EQUAL
                case .GreaterThan: return UsergridQuery.GREATER_THAN
                case .GreaterThanEqualTo: return UsergridQuery.GREATER_THAN_EQUAL_TO
                case .LessThan: return UsergridQuery.LESS_THAN
                case .LessThanEqualTo: return UsergridQuery.LESS_THAN_EQUAL_TO
            }
        }
    }

    @objc public enum QuerySortOrder: Int {
        case Asc
        case Desc
        static func fromString(stringValue: String) -> QuerySortOrder? {
            switch stringValue.lowercaseString {
                case UsergridQuery.ASC: return .Asc
                case UsergridQuery.DESC: return .Desc
                default: return nil
            }
        }
        var stringValue: String {
            switch self {
                case .Asc: return UsergridQuery.ASC
                case .Desc: return UsergridQuery.DESC
            }
        }
    }
}