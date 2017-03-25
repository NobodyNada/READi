//
//  RequestsPrivileges.swift
//  SwiftStack
//
//  Created by FelixSFD on 14.02.17.
//
//

import Foundation

/**
 This extension contains all requests in the PRIVILEGES section of the StackExchange API Documentation.
 
 - authors: NobodyNada, FelixSFD
 */
public extension APIClient {
    
    // - MARK: /privileges
    
    /**
     Fetches all `Privileges`s synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of sites as `APIResponse<Privilege>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchPrivileges(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Privilege> {
        
        
        return try performAPIRequest(
            "privileges",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all `Privileges`s asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler: Passes either an `APIResponse<Privilege>?` or an `Error?`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchPrivileges(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Privilege>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Privilege> = try self.fetchPrivileges(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
}

