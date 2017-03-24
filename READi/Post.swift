//
//  Post.swift
//  READi
//
//  Created by NobodyNada on 3/22/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class Post: CustomStringConvertible {
	var id: Int!	//The MS ID, not the SE ID!
	var title: String!
	var body: String!
	var why: String!
	var feedback: [PostFeedback]!
	
	static let FeedbackUpdatedNotification = Notification.Name("READi.Post.FeedbackUpdatedNotification")
	static let FeedbackFailedNotification = Notification.Name("READi.Post.FeedbackFailedNotification")
	static let FlagFailedNotification = Notification.Name("READi.Post.FlagFailedNotification")
	
	func postFeedbackNotification() {
		DispatchQueue.main.async {
			NotificationCenter.default.post(Notification(name: Post.FeedbackUpdatedNotification, object: self, userInfo: nil))
		}
	}
	
	class PostFeedback {
		var id: Int!
		var username: String!
		var type: Feedback!
		
		init() {
			
		}
		
		init(json: [String:Any]) {
			id = json["id"] as? Int
			username = json["user_name"] as? String
			
			if let typeName = json["feedback_type"] as? String {
				switch typeName {
				case "tpu", "tpu-":
					type = .spam
				case "tp", "tp-":
					type = .vandalism
				case "naa", "naa-":
					type = .naa
				case "fp", "fp-", "fpu", "fpu-":
					type = .fp
				default:
					break
				}
			}
		}
		
		class func from(json: [[String:Any]]) -> [PostFeedback] {
			return json.map { PostFeedback(json: $0) }
		}
		
		class func from(json: [String:Any]) -> [PostFeedback] {
			return from(json: (json["items"] as? [[String:Any]]) ?? [])
		}
	}
	
	
	init() {
		
	}
	
	init(json: [String:Any]) {
		body = json["body"] as? String
		id = json["id"] as? Int
		title = json["title"] as? String
		why = json["why"] as? String
	}
	
	var description: String {
		return title ?? "<no title>"
	}
	
	func fetchFeedback(client: Client) throws {
		guard id != nil else { return }
		
		let response: String = try client.get(
			"https://metasmoke.erwaysoftware.com/api/post/\(id!)/feedback" +
			"?per_page=\(100)&key=\(client.key)"
		)
		
		guard let json = try client.parseJSON(response) as? [String:Any] else {
			return
		}
		
		feedback = PostFeedback.from(json: json)
	}
	
	class func from(json: [String:Any]) -> [Post] {
		return (json["items"] as? [[String:Any]])?.map { Post(json: $0) } ?? []
	}
	
	
	enum PostError: Error {
		case feedbackFailed(details: String?)
		case spamFlagFailed(details: String?)
	}
	
	func send(feedback: Feedback) {
		(UIApplication.shared.delegate as! AppDelegate).getWriteToken {writeToken in
			guard let token = writeToken else { return }
			
			DispatchQueue.global(qos: .background).async {
				do {
					let response: String = try client.post("https://metasmoke.erwaysoftware.com/api/w/post/\(self.id!)/feedback", [
						"key":client.key,
						"token":token,
						"type":feedback.identifier
						]
					)
					
					let json = try client.parseJSON(response)
					
					if let errorDetails = json as? [String:Any] {
						print(errorDetails)
						throw PostError.feedbackFailed(details: errorDetails["error_message"] as? String)
					}
					
					guard let feedbacks = json as? [[String:Any]] else {
						print("Could not parse feedback!")
						throw PostError.feedbackFailed(details: nil)
					}
					
					
					self.feedback = PostFeedback.from(json: feedbacks)
					self.postFeedbackNotification()
				} catch PostError.feedbackFailed(let details) {
					print("Could not send feedback!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Post.FeedbackFailedNotification,
							object: self,
							userInfo: ["errorDetails":details as Any]
						)
					}
				} catch {
					print("Could not send feedback!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Post.FeedbackFailedNotification,
							object: self
						)
					}
				}
			}
		}
		
	}
	
	
	
	//Flags a post as spam.
	func flag() {
		(UIApplication.shared.delegate as! AppDelegate).getWriteToken {writeToken in
			guard let token = writeToken else { return }
			
			
			DispatchQueue.global(qos: .background).async {
				do {
					guard let response = try client.parseJSON(
						client.post("https://metasmoke.erwaysoftware.com/api/w/post/\(self.id!)/spam_flag", [
							"key":client.key,
							"token":token
							]
						)
					) as? [String:Any] else {
							throw PostError.spamFlagFailed(details: nil)
					}
					
					if response["status"] as? String == "failed" {
						throw PostError.spamFlagFailed(details: response["message"] as? String)
					}
					
					print(response)
					
				} catch PostError.spamFlagFailed(let details) {
					print("Failed to flag as spam!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Post.FlagFailedNotification,
							object: self,
							userInfo: ["errorDetails":details as Any]
						)
					}
				} catch {
					print("Failed to flag as spam!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Post.FlagFailedNotification,
							object: self
						)
					}
				}
			}
			
			
		}
	}
}
