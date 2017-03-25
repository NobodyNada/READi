//
//  RequestsQuestions.swift
//  SwiftStack
//
//  Created by NobodyNada on 17.12.16.
//
//

import Foundation
import Dispatch

/**
This extension contains all requests in the QUESTIONS section of the StackExchange API Documentation.

- author: NobodyNada, FelixSFD
*/
public extension APIClient {
	// - MARK: /questions
    /**
     Fetches all questions on the site synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - author: FelixSFD
     */
    public func fetchQuestions(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        return try performAPIRequest(
            "questions",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all questions on the site asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - parameter completion
     
     - author: FelixSFD
     */
    public func fetchQuestions(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchQuestions(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    
	// - MARK: /questions/{ids}
    /**
     Fetches questions synchronously.
	
	 - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an APIRequest has a backoff
     
     - returns: The list of sites as `APIResponse<Question>`
     
     - author: NobodyNada
     */
	public func fetchQuestions(
		_ ids: [Int],
		parameters: [String:String] = [:],
		backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
		
		guard !ids.isEmpty else {
			fatalError("ids is empty")
		}
		
		
		return try performAPIRequest(
			"questions/\(ids.map {String($0)}.joined(separator: ";"))",
			parameters: parameters,
			backoffBehavior: backoffBehavior
		)
	}
    
    /**
	 Fetches questions asynchronously.
	
	 - parameter ids: The question IDs to fetch.
	
	 - parameter parameters: The dictionary of parameters used in the request
	
	 - parameter backoffBehavior: The behavior when an APIRequest has a backoff
	
	 - parameter completion
	
      - author: NobodyNada
     */
    public func fetchQuestions(
		_ ids: [Int],
		parameters: [String: String] = [:],
		backoffBehavior: BackoffBehavior = .wait,
		completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
				let response: APIResponse<Question> = try self.fetchQuestions(
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
	Fetches a question synchronously.
	
	- parameter ids: The question IDs to fetch.
	
	- parameter parameters: The dictionary of parameters used in the request
	
	- parameter backoffBehavior: The behavior when an APIRequest has a backoff
	
	- returns: The list of sites as `APIResponse<Question>`
	
	- author: NobodyNada
	*/
	public func fetchQuestion(
		_ id: Int,
		parameters: [String:String] = [:],
		backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
		
		return try fetchQuestions([id], parameters: parameters, backoffBehavior: backoffBehavior)
	}
	
	/**
	Fetches a question asynchronously.
	
	- parameter ids: The question IDs to fetch.
	
	- parameter parameters: The dictionary of parameters used in the request
	
	- parameter backoffBehavior: The behavior when an APIRequest has a backoff
	
	- parameter completion
	
	- author: NobodyNada
	*/
	public func fetchQuestion(
		_ id: Int,
		parameters: [String: String] = [:],
		backoffBehavior: BackoffBehavior = .wait,
		completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
		
		fetchQuestions([id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
	}
    
    
    // - MARK: /questions/{ids}/answers
    
    /**
     Fetches `Answer`s on `Question`s synchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of answers as `APIResponse<Answer>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswersOn(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Answer> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "questions/\(ids.map {String($0)}.joined(separator: ";"))/answers",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches `Answer`s on `Question`s asynchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswersOn(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Answer>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Answer> = try self.fetchAnswersOn(questions: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches `Answer`s on a single `Question` synchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of answers as `APIResponse<Answer>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswersOn(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Answer> {
        return try fetchAnswersOn(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches `Answer`s on a single `Question` asynchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchAnswersOn(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Answer>?, Error?) -> ()) {
        
        fetchAnswersOn(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    // - MARK: /questions/{ids}/comments
    
    /**
     Fetches `Comment`s on `Question`s synchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of comments as `APIResponse<Comment>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Comment> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "questions/\(ids.map {String($0)}.joined(separator: ";"))/comments",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches `Comment`s on `Question`s asynchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Comment>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Comment> = try self.fetchCommentsOn(questions: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches `Comment`s on a single `Question` synchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of comments as `APIResponse<Comment>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Comment> {
        return try fetchCommentsOn(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches `Comment`s on a single `Question` asynchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchCommentsOn(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Comment>?, Error?) -> ()) {
        
        fetchCommentsOn(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    // - MARK: /questions/{ids}/linked
    
    /**
     Fetches linked `Question`s to `Question`s synchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchLinkedQuestionsTo(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "questions/\(ids.map {String($0)}.joined(separator: ";"))/linked",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches linked `Question`s to `Question`s asynchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchLinkedQuestionsTo(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchLinkedQuestionsTo(questions: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches linked `Question`s to a single `Question` synchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchLinkedQuestionsTo(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        return try fetchLinkedQuestionsTo(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches linked `Question`s to a single `Question`  asynchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchLinkedQuestionsTo(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        fetchLinkedQuestionsTo(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    // - MARK: /questions/{ids}/related
    
    /**
     Fetches related `Question`s to `Question`s synchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRelatedQuestionsTo(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "questions/\(ids.map {String($0)}.joined(separator: ";"))/related",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches related `Question`s to `Question`s asynchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRelatedQuestionsTo(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchRelatedQuestionsTo(questions: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches related `Question`s to a single `Question` synchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRelatedQuestionsTo(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        return try fetchRelatedQuestionsTo(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches related `Question`s to a single `Question`  asynchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchRelatedQuestionsTo(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        fetchRelatedQuestionsTo(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    // - MARK: /questions/{ids}/timeline
    
    /**
     Fetches the `Question.Timeline` events of `Question`s synchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question.Timeline>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchTimelineOf(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question.Timeline> {
        
        guard !ids.isEmpty else {
            fatalError("ids is empty")
        }
        
        
        return try performAPIRequest(
            "questions/\(ids.map {String($0)}.joined(separator: ";"))/timeline",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches the `Question.Timeline` events of `Question`s asynchronously.
     
     - parameter ids: The question IDs to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchTimelineOf(
        questions ids: [Int],
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question.Timeline>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question.Timeline> = try self.fetchTimelineOf(questions: ids, parameters: parameters, backoffBehavior: backoffBehavior)
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    /**
     Fetches the `Question.Timeline` events of a single `Question` synchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question.Timeline>`
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchTimelineOf(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question.Timeline> {
        return try fetchTimelineOf(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior)
    }
    
    /**
     Fetches the `Question.Timeline` events of a single `Question` asynchronously.
     
     - parameter id: The question ID to fetch.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completionHandler:
     
     - authors: NobodyNada, FelixSFD
     */
    public func fetchTimelineOf(
        question id: Int,
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question.Timeline>?, Error?) -> ()) {
        
        fetchTimelineOf(questions: [id], parameters: parameters, backoffBehavior: backoffBehavior, completionHandler: completionHandler)
    }
    
    
    
    // - MARK: /questions/featured
    /**
     Fetches all questions with active bounties on the site synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - author: FelixSFD
     */
    public func fetchFeaturedQuestions(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        return try performAPIRequest(
            "questions/featured",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all questions with active bounties on the site asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completion
     
     - author: FelixSFD
     */
    public func fetchFeaturedQuestions(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchQuestions(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    
    
    // - MARK: /questions/no-answers
    /**
     Fetches all questions with no answers on the site synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - seealso: fetchUnansweredQuestions(parameters:backoffBehavior:)
     
     - author: FelixSFD
     */
    public func fetchQuestionsWithNoAnswers(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        return try performAPIRequest(
            "questions/no-answers",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all questions with no answers on the site asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completion
     
     - seealso: fetchUnansweredQuestions(parameters:backoffBehavior:completionHandler:)
     
     - author: FelixSFD
     */
    public func fetchQuestionsWithNoAnswers(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchQuestions(
                    parameters: parameters,
                    backoffBehavior: backoffBehavior
                )
                
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
    }
    
    
    
    // - MARK: /questions/unanswered
    /**
     Fetches all questions the site considers unanswered synchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - returns: The list of questions as `APIResponse<Question>`
     
     - seealso: fetchQuestionsWithNoAnswers(parameters:backoffBehavior:)
     
     - author: FelixSFD
     */
    public func fetchUnansweredQuestions(
        parameters: [String:String] = [:],
        backoffBehavior: BackoffBehavior = .wait) throws -> APIResponse<Question> {
        
        return try performAPIRequest(
            "questions/unanswered",
            parameters: parameters,
            backoffBehavior: backoffBehavior
        )
    }
    
    /**
     Fetches all questions the site considers unanswered asynchronously.
     
     - parameter parameters: The dictionary of parameters used in the request
     
     - parameter backoffBehavior: The behavior when an `APIRequest` has a backoff
     
     - parameter completion
     
     - seealso: fetchQuestionsWithNoAnswers(parameters:backoffBehavior:completionHandler:)
     
     - author: FelixSFD
     */
    public func fetchUnansweredQuestions(
        parameters: [String: String] = [:],
        backoffBehavior: BackoffBehavior = .wait,
        completionHandler: @escaping (APIResponse<Question>?, Error?) -> ()) {
        
        queue.async {
            do {
                let response: APIResponse<Question> = try self.fetchQuestions(
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
