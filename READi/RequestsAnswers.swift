//
//  RequestsAnswers.swift
//  SwiftStack
//
//  Created by FelixSFD on 14.01.17.
//
//

import Foundation

/**
 This extension contains all requests in the QUESTIONS section of the StackExchange API Documentation.
 
 - authors: NobodyNada, FelixSFD
 */
public extension APIClient {
    // - MARK: /answers
    /**
     Fetches all answers on the site synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of questions as `APIResponse<Answer>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswers(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Answer> {
        
        return try performAPIRequest(
            "answers",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all answers on the site asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completion
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswers(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Answer>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Answer> = try self.fetchAnswers(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    
    // - MARK: /answers/{ids}
    /**
     Fetches answers synchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Answer>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswers(
        _ ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Answer> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "answers/\(ids.map {String($0)}.joined(separator: ";"))",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches answers asynchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswers(
        _ ids: [Int],
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Answer>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Answer> = try self.fetchAnswers(
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
     Fetches an answer synchronously.
     
     - parameter ids: The answer ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Answer>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswer(
        _ id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Answer> {
        
        return try fetchAnswers([id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches an answer asynchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswer(
        _ id: Int,
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Answer>?, Error?) -> ()) {
        
        fetchAnswers([id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    // - MARK: /answers/{ids}/comments
    
    /**
     Fetches `Comment`s on `Answer`s synchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of comments as `APIResponse<Comment>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        answers ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Comment> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "answers/\(ids.map {String($0)}.joined(separator: ";"))/comments",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches `Comment`s on `Answer`s asynchronously.
     
     - parameter ids: The answers IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        answers ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Comment>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Comment> = try self.fetchCommentsOn(answers: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches `Comment`s on a single `Answer` synchronously.
     
     - parameter id: The answer ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of comments as `APIResponse<Comment>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        answer id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Comment> {
        return try fetchCommentsOn(answers: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches `Comment`s on a single `Answer` asynchronously.
     
     - parameter id: The answer ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        answer id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Comment>?, Error?) -> ()) {
        
        fetchCommentsOn(answers: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    
    // - MARK: /answers/{ids}/questions
    
    /**
     Fetches questions of answers synchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchQuestionsOfAnswers(
        _ ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "answers/\(ids.map {String($0)}.joined(separator: ";"))/questions",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches questions of answers asynchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchQuestionsOfAnswers(
        _ ids: [Int],
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchQuestionsOfAnswers(
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
     Fetches the question of an answer synchronously.
     
     - parameter ids: The answer ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchQuestionOfAnswer(
        _ id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        return try fetchQuestionsOfAnswers([id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches the question of an answer asynchronously.
     
     - parameter ids: The answer IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completionHandler
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchQuestionOfAnswer(
        _ id: Int,
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        fetchQuestionsOfAnswers([id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
}
