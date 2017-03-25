//
//  RequestsRevisions.swift
//  SwiftStack
//
//  Created by FelixSFD on 21.12.16.
//
//

import Foundation

/**
 This extension contains all requests in the REVISIONS section of the StackExchange API Documentation.
 
 - authors: NobodyNada, FelixSFD
 */
public extension APIClient {
    // - MARK: /revisions/{ids}
    
    /**
     Fetches revisions synchronously.
     
     - parameter ids: The revision IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Revision>`
     
     - note: Unlike most other id types in the API, `ids` representing `Revision.revision_guid`s is a `[String]`.
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRevisions(
        _ ids: [String],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Revision> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "revisions/\(ids.map {$0}.joined(separator: ";"))",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches revisions asynchronously.
     
     - parameter ids: The revisions IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<Revision>?` or an `Error?`
     
     - note: Unlike most other id types in the API, `ids` representing `Revision.revision_guid`s is a `[String]`.
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRevisions(
        _ ids: [String],
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Revision>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Revision> = try self.fetchRevisions(
                    ids,
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches a revision synchronously.
     
     - parameter id: The revision ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - note: Unlike most other id types in the API, `id` representing `Revision.revision_guid` is a `String`.
     
     - returns: The list of sites as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRevision(
        _ id: String,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Revision> {
        
        return try fetchRevisions([id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches a revision asynchronously.
     
     - parameter id: The revision ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<Revision>?` or an `Error?`
     
     - note: Unlike most other id types in the API, `id` representing `Revision.revision_guid` is a `String`.
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRevision(
        _ id: String,
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Revision>?, Error?) -> ()) {
        
        fetchRevisions([id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
}
