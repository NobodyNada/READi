//
//  Client.swift
//  FireAlarm
//
//  Created by NobodyNada on 8/27/16.
//  Copyright © 2016 NobodyNada. All rights reserved.
//

import Foundation
import Dispatch
import UIKit

//MARK: - Convenience extensions

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

func + <K, V> (left: [K:V], right: [K:V]) -> [K:V] {
	var result = left
	for (k, v) in right {
		result[k] = v
	}
	return result
}

//https://stackoverflow.com/a/24052094/3476191
func += <K, V> (left: inout [K:V], right: [K:V]) {
	for (k, v) in right {
		left[k] = v
	}
}

//MARK: -
///A Client handles HTTP requests, cookie management, and logging in to Stack Exchange chat.
open class Client: NSObject, URLSessionDataDelegate {
	//MARK: Instance variables
	open var session: URLSession {
		return URLSession(
			configuration: configuration,
			delegate: self, delegateQueue: delegateQueue
		)
	}
	open var cookies = [HTTPCookie]()
	open let queue = DispatchQueue(label: "Client queue", attributes: .concurrent)
	
	open var loggedIn = false
	
	//The Metasmoke key.
	open var key: String
	
	private var configuration: URLSessionConfiguration
	private var delegateQueue: OperationQueue
	
	public enum RequestError: Error {
		case invalidURL(url: String)
		case notUTF8
		case unknownError
	}
	
	
	
	
	
	//MARK: - Private variables
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
	
	private var tasks = [URLSessionTask:HTTPTask]() {
		didSet {
			UIApplication.shared.isNetworkActivityIndicatorVisible = !tasks.isEmpty
		}
	}
	
	private var responseSemaphore: DispatchSemaphore?
	
	
	
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
	
	private func performTask(_ task: URLSessionTask, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
		tasks[task] = HTTPTask(task: task, completion: completion)
		task.resume()
	}
	
	
	
	//MARK:- Request methods.
	
	///Performs an `URLRequest`.
	///- parameter request: The request to perform.
	///- returns: The `Data` and `HTTPURLResponse` returned by the request.
	open func performRequest(_ request: URLRequest) throws -> (Data, HTTPURLResponse) {
		let req = request
		
		let sema = DispatchSemaphore(value: 0)
		var data: Data!
		var resp: URLResponse!
		var error: Error!
		
		
		let task = self.session.dataTask(with: req)
		self.performTask(task) {inData, inResp, inError in
			(data, resp, error) = (inData, inResp, inError)
			sema.signal()
		}
		
		
		sema.wait()
		
		guard let response = resp as? HTTPURLResponse, data != nil else {
			throw error
		}
		
		return (data, response)
	}
	
	
	
	///Performs a GET request.
	///- paramter url: The URL to make the request to.
	///- returns: The `Data` and `HTTPURLResponse` returned by the request.
	open func get(_ url: String) throws -> (Data, HTTPURLResponse) {
		guard let nsUrl = URL(string: url) else {
			throw RequestError.invalidURL(url: url)
		}
		var request = URLRequest(url: nsUrl)
		request.setValue(String(request.httpBody?.count ?? 0), forHTTPHeaderField: "Content-Length")
		return try performRequest(request)
	}
	
	
	
	///Performs a POST request.
	///- parameter url: The URL to make the request to.
	///- parameter data: The fields to include in the POST request.
	///- returns: The `Data` and `HTTPURLResponse` returned by the request.
	open func post(_ url: String, _ data: [String:String]) throws -> (Data, HTTPURLResponse) {
		guard let nsUrl = URL(string: url) else {
			throw RequestError.invalidURL(url: url)
		}
		guard let data = String(urlParameters: data).data(using: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		var request = URLRequest(url: nsUrl)
		request.httpMethod = "POST"
		
		
		let sema = DispatchSemaphore(value: 0)
		
		var responseData: Data?
		var resp: HTTPURLResponse?
		var responseError: Error?
		
		let task = self.session.uploadTask(with: request, from: data)
		self.performTask(task) {data, response, error in
			(responseData, resp, responseError) = (data, response, error)
			sema.signal()
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
	
	
	
	
	
	///Performs an URLRequest.
	///- parameter request: The request to perform.
	///- returns: The UTF-8 string returned by the request.
	open func performRequest(_ request: URLRequest) throws -> String {
		let (data, _) = try performRequest(request)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	
	
	///Performs a GET request.
	///- paramter url: The URL to make the request to.
	///- returns: The UTF-8 string returned by the request.
	open func get(_ url: String) throws -> String {
		let (data, _) = try get(url)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	
	///Performs a POST request.
	///- parameter url: The URL to make the request to.
	///- parameter data: The fields to include in the POST request.
	///- returns: The UTF-8 string returned by the request.
	open func post(_ url: String, _ fields: [String:String]) throws -> String {
		let (data, _) = try post(url, fields)
		guard let string = String(data: data, encoding: String.Encoding.utf8) else {
			throw RequestError.notUTF8
		}
		return string
	}
	
	
	
	
	///Parses a JSON string.
	open func parseJSON(_ json: String) throws -> Any {
		return try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments)
	}
	
	
	
	
	//MARK: - Initializers.
	
	///Initializes a Client.
	///- parameter host: The chat host to log in to.
	public init(key: String) {
		self.key = key
		
		let configuration =  URLSessionConfiguration.default
		configuration.httpCookieStorage = nil
		self.configuration = configuration
		
		let delegateQueue = OperationQueue()
		delegateQueue.maxConcurrentOperationCount = 1
		self.delegateQueue = delegateQueue
		
		super.init()
		
		/*configuration.connectionProxyDictionary = [
		"HTTPEnable" : 1,
		kCFNetworkProxiesHTTPProxy as AnyHashable : "192.168.1.234",
		kCFNetworkProxiesHTTPPort as AnyHashable : 8080,
		
		"HTTPSEnable" : 1,
		kCFNetworkProxiesHTTPSProxy as AnyHashable : "192.168.1.234",
		kCFNetworkProxiesHTTPSPort as AnyHashable : 8080
		]*/
	}
}
