//
//  APIClient.swift
//  SwiftStack
//
//  Created by NobodyNada on 12/2/16.
//
//

import Foundation
import Dispatch

extension String {
	var urlEncodedString: String {
		var allowed = CharacterSet.urlQueryAllowed
		allowed.remove(charactersIn: "&+")
		return self.addingPercentEncoding(withAllowedCharacters: allowed)!
	}
	
	init(urlParameters: [String:String]) {
		var result = [String]()
		
		for (key, value) in urlParameters {
			result.append("\(key.urlEncodedString)=\(value.urlEncodedString)")
		}
		
		self.init(result.joined(separator: "&"))!
	}
}

//MARK: -


///An APIClient communicates to the Stack Exchange API over HTTP.
open class APIClient: NSObject, URLSessionDataDelegate {
	//MARK: Instance variables and types.
	
	///The URLSession for this client.
	open var session: URLSession!
	
	///The queue used for asynchronous operations.
	open let queue = DispatchQueue(label: "API queue", attributes: [.concurrent])
	
	///The API key to use.
	open var key: String?
	
	///The Metasmoke key to use.
	open var metasmokeKey: String!
	
	///Which API filter to use if none is specified.
	open var defaultFilter: String?
	
	///Whether to use a secure connection to communicate with the API.
	open var useSSL: Bool = true
	
	///Which site to use if none is specified.
	open var defaultSite: String = "stackoverflow"
	
	///The API quota remaining, or `nil` if it is not known.
	open private(set) var quota: Int?
	
	///The maximum API quota, or `nil` if it is not known.
	open private(set) var maxQuota: Int?
	
	
	///The methods which have
	open var backoffs = [String:Date]()
	
	///Errors that can occur while performing a HTTP request.
	public enum RequestError: Error {
		///The URL provided was invalid.
		case invalidURL(url: String)
		
		///The text or data provided was not valid UTF-8.
		case notUTF8
		
		case unknownError
	}
	
	///API-specific errors.
	public enum APIError: Error {
		///The data returned by the API was not a dictionary.
		case notDictionary(response: String)
		
		///The API returned an error.
		case apiError(id: Int?, message: String?)
		
		///A backoff was recieved and `backoffBehavior` was `.throwError`.
		case backoff(expiration: Date)
	}
	
	public enum BackoffBehavior {
		case wait
		case throwError
	}
	
	///Performs an API request.  All functions using API calls should funnel into this one.
	///
	///- parameter request: The request to make, for example `users/{ids}/answers`.
	///- parameter parameters: Parameters to be URLEncoded into the request.
	open func performAPIRequest<T>(
		_ request: String,
		parameters: [String:String] = [:],
		backoffBehavior: BackoffBehavior = .wait
		) throws -> APIResponse<T> {
		
		var params = parameters
		
		//Add default parameter values.
		if let k = key, params["key"] == nil {
			params["key"] = k
		}
		
		if let f = defaultFilter, params["filter"] == nil {
			params["filter"] = f
		}
		
		if params["site"] == nil {
			params["site"] = defaultSite
		}
		else if params["site"] == "" {
			params["site"] = nil
		}
		
		//Build the URL.
		var url = "\(useSSL ? "https" : "http")://api.stackexchange.com/2.2"
		
		let prefixedRequest = (request.hasPrefix("/") ? request : "/" + request)
		url += prefixedRequest
		
		let queryString = String(urlParameters: params)
		if !queryString.isEmpty {
			url += "?" + queryString
		}
		
		
		cleanBackoffs()
		
		let backoffName: String
		let pathComponents = prefixedRequest.components(separatedBy: "/")
		if pathComponents.count >= 2 {
			backoffName = pathComponents[1]
		} else {
			backoffName = ""
		}
		
		//If there is a backoff for this request, wait for the backoff to
		//expire or throw an error, depending on the backoff behavior.
		if let backoffExpiration = backoffs[backoffName] {
			switch backoffBehavior {
			case .wait: wait(until: backoffExpiration)
			case .throwError: throw APIError.backoff(expiration: backoffExpiration)
				
			}
		}
		
		
		//Perform the request.
		let response: String = try get(url)
		guard let json = try parseJSON(response) as? [String:Any] else {
			throw APIError.notDictionary(response: response)
		}
		
		let apiResponse = APIResponse<T>(dictionary: json)
		
		if let backoff = apiResponse.backoff {
			backoffs[backoffName] = Date().addingTimeInterval(TimeInterval(backoff))
		}
		cleanBackoffs()
		
		guard apiResponse.error_id == nil, apiResponse.error_message == nil else {
			throw APIError.apiError(id: json["error_id"] as? Int, message: json["error_message"] as? String)
		}
		
		
		maxQuota = apiResponse.quota_max ?? maxQuota
		quota = apiResponse.quota_remaining ?? quota
		
		return apiResponse
	}
	
	internal func wait(until date: Date) {
		Thread.sleep(until: date)
	}
	
	private func cleanBackoffs() {
		//Remove backoffs that have expired.
		var filteredBackoffs = [String:Date]()
		let now = Date()
		for (request, expiration) in backoffs {
			if now < expiration {
				filteredBackoffs[request] = expiration
			}
		}
		backoffs = filteredBackoffs
	}
	
	
	
	//MARK: - Functions for performing requests.
	
	///Performs an URLRequest.
	///
	///- warning: On Linux, this function will not work to perform a POST request.
	///- parameter request: The request to perform.
	///- returns: The data and response returned by the request.
	open func performRequest(_ request: URLRequest) throws -> (Data, HTTPURLResponse) {
		let req = request
		
		let sema = DispatchSemaphore(value: 0)
		var data: Data!
		var resp: URLResponse!
		var error: Error!
		
		
		
		//TODO: I don't think this needs to be on the client queue anymore
		queue.async {
			let task = self.session.dataTask(with: req)
			self.performTask(task) {inData, inResp, inError in
				(data, resp, error) = (inData, inResp, inError)
				sema.signal()
			}
			
		}
		
		sema.wait()
		
		guard let response = resp as? HTTPURLResponse, data != nil else {
			throw error
		}
		
		return (data, response)
	}
	
	///Performs a GET request to the specified URL.
	///
	///- parameter url: The URL to send the request to.
	///- returns: The data and response returned by the request.
	open func get(_ url: String) throws -> (Data, HTTPURLResponse) {
		guard let nsUrl = URL(string: url) else {
			throw RequestError.invalidURL(url: url)
		}
		var request = URLRequest(url: nsUrl)
		request.setValue(String(request.httpBody?.count ?? 0), forHTTPHeaderField: "Content-Length")
		return try performRequest(request)
	}
	
	///Performs a POST request to the specifed URL.
	///
	///- parameters:
	///	- url: The URL to send the request to.
	///	- fields: The data to POST.
	///
	///- returns: The data and response returned by the request.
	open func post(_ url: String, fields: [String:String]) throws -> (Data, HTTPURLResponse) {
		guard let nsUrl = URL(string: url) else {
			throw RequestError.invalidURL(url: url)
		}
		guard let data = String(urlParameters: fields).data(using: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		var request = URLRequest(url: nsUrl)
		request.httpMethod = "POST"
		
		
		
		let sema = DispatchSemaphore(value: 0)
		
		var responseData: Data?
		var resp: HTTPURLResponse?
		var responseError: Error?
		
		queue.async {
			let task = self.session.uploadTask(with: request, from: data)
			self.performTask(task) {data, response, error in
				(responseData, resp, responseError) = (data, response, error)
				sema.signal()
			}
		}
		
		sema.wait()
		
		
		guard let response = resp else {
			throw responseError ?? RequestError.unknownError
		}
		
		if responseData == nil {
			responseData = Data()
		}
		
		return (responseData!, response)
	}
	
	
	
	//MARK: - Convenience functions for performing requests.
	
	///Performs an URLRequest.
	///
	///- warning: On Linux, this function will not work to perform a POST request.
	///- parameter request: The request to perform.
	///- returns: The text returned by the request.
	open func performRequest(_ request: URLRequest) throws -> String {
		let (data, _) = try performRequest(request)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	
	///Performs a GET request to the specified URL.
	///
	///- parameter url: The URL to send the request to.
	///- returns: The text returned by the request.
	open func get(_ url: String) throws -> String {
		let (data, _) = try get(url)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	///Performs a POST request to the specifed URL.
	///
	///- parameters:
	///	- url: The URL to send the request to.
	///	- fields: The data to POST.
	///
	///- returns: The text returned by the request.
	open func post(_ url: String, fields: [String:String]) throws -> String {
        let (data, _) = try post(url, fields: fields)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	///Parses JSON using JSONSerialization.
	///- parameter json: The JSON to parse.
	///- returns: The parsed JSON.
	open func parseJSON(_ json: String) throws -> Any {
		return try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments)
	}
	
	
	
	
	
	//MARK: - Initializers
	
	///Initializes an APIClient with an optional proxy.
	///- parameter proxyAddress: The address of the proxy to use, or `nil` for no proxy.  Default is `nil`.
	///- parameter proxyPort: The port on the proxy server to connect to.
	public init(proxyAddress: String? = nil, proxyPort: Int = 80, metasmokeKey: String? = nil) {
		super.init()
		
		let configuration =  URLSessionConfiguration.default
		
		if proxyAddress != nil {
			#if os(macOS)
				configuration.connectionProxyDictionary = [
					"HTTPEnable" : 1,
					kCFNetworkProxiesHTTPProxy as AnyHashable : proxyAddress!,
					kCFNetworkProxiesHTTPPort as AnyHashable : proxyPort,
					
					"HTTPSEnable" : 1,
					kCFNetworkProxiesHTTPSProxy as AnyHashable : proxyAddress!,
					kCFNetworkProxiesHTTPSPort as AnyHashable : proxyPort
				]
			#else
				fatalError("proxies are only supported on macOS")
			#endif
		}
		
		configuration.httpCookieStorage = nil
		
		
		let delegateQueue = OperationQueue()
		delegateQueue.maxConcurrentOperationCount = 1
		
		session = URLSession(
			configuration: configuration,
			delegate: self, delegateQueue: delegateQueue
		)
		
		self.metasmokeKey = metasmokeKey
	}
	
	
	
	
	
	
	//MARK: - Task management
	private class HTTPTask {
		var task: URLSessionTask
		var completion: (Data?, HTTPURLResponse?, Error?) -> Void
		
		var data: Data?
		var response: HTTPURLResponse?
		var error: Error?
		
		init(task: URLSessionTask, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
			self.task = task
			self.completion = completion
		}
	}
	
	private var tasks = [URLSessionTask:HTTPTask]()
	
	private var responseSemaphore: DispatchSemaphore?
	
	
	internal func performTask(_ task: URLSessionTask, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
		tasks[task] = HTTPTask(task: task, completion: completion)
		task.resume()
	}
	
	
	
	
	
	
	//MARK: - URLSession delegate methods
	public func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive response: URLResponse,
		completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
		
		guard let task = tasks[dataTask] else {
			print("\(dataTask) is not in client task list; cancelling")
			completionHandler(.cancel)
			return
		}
		
		var headers = [String:String]()
		for (k, v) in (response as? HTTPURLResponse)?.allHeaderFields ?? [:] {
			headers[String(describing: k)] = String(describing: v)
		}
		
		
		task.response = response as? HTTPURLResponse
		completionHandler(.allow)
	}
	
	public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		guard let task = tasks[dataTask] else {
			print("\(dataTask) is not in client task list; ignoring")
			return
		}
		
		if task.data != nil {
			task.data!.append(data)
		}
		else {
			task.data = data
		}
	}
	
	public func urlSession(_ session: URLSession, task sessionTask: URLSessionTask, didCompleteWithError error: Error?) {
		guard let task = tasks[sessionTask] else {
			print("\(sessionTask) is not in client task list; ignoring")
			return
		}
		task.error = error
		
		task.completion(task.data, task.response, task.error)
		
		
		tasks[sessionTask] = nil
	}
	
	public func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		willPerformHTTPRedirection response: HTTPURLResponse,
		newRequest request: URLRequest,
		completionHandler: @escaping (URLRequest?) -> Void
		) {
		
		var headers = [String:String]()
		for (k, v) in response.allHeaderFields {
			headers[String(describing: k)] = String(describing: v)
		}
		
		completionHandler(request)
	}
	
	
	
	deinit {
		session.invalidateAndCancel()
	}
}
