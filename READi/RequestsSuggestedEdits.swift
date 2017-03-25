//
//  RequestsSuggestedEdits.swift
//  SwiftStack
//
//  Created by FelixSFD on 22.12.16.
//
//

import Foundation

/**
 This extension contains all requests in the SUGGESTED EDITS section of the StackExchange API Documentation.
 
 - authors: NobodyNada, FelixSFD
 */
public extension APIClient {
    
    // - MARK: /suggested-edits
    
    /**
     Fetches all `SuggestedEdit`s synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of sites as `APIResponse<SuggestedEdit>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdits(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<SuggestedEdit> {
        
        
        return try performAPIRequest(
            "suggested-edits",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all `SuggestedEdit`s asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<SuggestedEdit>?` or an `Error?`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdits(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<SuggestedEdit>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<SuggestedEdit> = try self.fetchSuggestedEdits(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    
    // - MARK: /suggested-edits/{ids}
    
    /**
     Fetches `SuggestedEdit`s synchronously.
     
     - parameter ids: The IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of sites as `APIResponse<SuggestedEdit>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdits(
        _ ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<SuggestedEdit> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "suggested-edits/\(ids.map {String($0)}.joined(separator: ";"))",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches `SuggestedEdit`s asynchronously.
     
     - parameter ids: The IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<SuggestedEdit>?` or an `Error?`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdits(
        _ ids: [Int],
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<SuggestedEdit>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<SuggestedEdit> = try self.fetchSuggestedEdits(
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
     Fetches a `SuggestedEdit` synchronously.
     
     - parameter id: The ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<SuggestedEdit>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdit(
        _ id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<SuggestedEdit> {
        
        return try fetchSuggestedEdits([id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches a `SuggestedEdit` asynchronously.
     
     - parameter id: The ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<SuggestedEdit>?` or an `Error?`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchSuggestedEdit(
        _ id: Int,
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<SuggestedEdit>?, Error?) -> ()) {
        
        fetchSuggestedEdits([id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
}
