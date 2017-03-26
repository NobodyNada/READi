//
//  Post.swift
//  READi
//
//  Created by NobodyNada on 3/22/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit
import DTCoreText

class Report: CustomStringConvertible {
	var id: Int!	//The MS ID, not the SE ID!
	var title: String!
	var body: String!
	var why: String!
	var link: String!
	var feedback: [ReportFeedback]!
	
	//Use a dispatch queue to serialize access to the attributed body.
	private var attributedBodyQueue = DispatchQueue(label: "Attributed Body")
	private var _attributedBody: NSAttributedString?
	
	var attributedBody: NSAttributedString? {
		get {
			var result: NSAttributedString?
			attributedBodyQueue.sync {
				result = _attributedBody
			}
			return result
		} set {
			attributedBodyQueue.sync {
				_attributedBody = newValue
			}
		}
	}
	
	
	static let FeedbackUpdatedNotification = Notification.Name("READi.Report.FeedbackUpdatedNotification")
	static let FeedbackFailedNotification = Notification.Name("READi.Report.FeedbackFailedNotification")
	static let FlagFailedNotification = Notification.Name("READi.Reportt.FlagFailedNotification")
	
	func postFeedbackNotification() {
		DispatchQueue.main.async {
			NotificationCenter.default.post(Notification(name: Report.FeedbackUpdatedNotification, object: self, userInfo: nil))
		}
	}
	
	class ReportFeedback {
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
		
		class func from(json: [[String:Any]]) -> [ReportFeedback] {
			return json.map { ReportFeedback(json: $0) }
		}
		
		class func from(json: [String:Any]) -> [ReportFeedback] {
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
		link = json["link"] as? String
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
		
		feedback = ReportFeedback.from(json: json)
	}
	
	class func from(json: [String:Any]) -> [Report] {
		return (json["items"] as? [[String:Any]])?.map { Report(json: $0) } ?? []
	}
	
	
	enum ReportError: Error {
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
						throw ReportError.feedbackFailed(details: errorDetails["error_message"] as? String)
					}
					
					guard let feedbacks = json as? [[String:Any]] else {
						print("Could not parse feedback!")
						throw ReportError.feedbackFailed(details: nil)
					}
					
					
					self.feedback = ReportFeedback.from(json: feedbacks)
					self.postFeedbackNotification()
				} catch ReportError.feedbackFailed(let details) {
					print("Could not send feedback!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Report.FeedbackFailedNotification,
							object: self,
							userInfo: ["errorDetails":details as Any]
						)
					}
				} catch {
					print("Could not send feedback!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Report.FeedbackFailedNotification,
							object: self
						)
					}
				}
			}
		}
		
	}
	
	func renderAttributedText() {
		attributedBodyQueue.sync {
			self._attributedBody = NSAttributedString(
				htmlData: self.body.data(using: .utf8)!,
				options: [
					DTDefaultFontFamily:UIFont.systemFont(ofSize: UIFont.systemFontSize).familyName,
					DTDefaultFontSize:17.0,
					DTUseiOS6Attributes:true
				],
				documentAttributes: nil
			)
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
							throw ReportError.spamFlagFailed(details: nil)
					}
					
					if response["status"] as? String == "failed" {
						throw ReportError.spamFlagFailed(details: response["message"] as? String)
					}
					
					print(response)
					
				} catch ReportError.spamFlagFailed(let details) {
					print("Failed to flag as spam!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Report.FlagFailedNotification,
							object: self,
							userInfo: ["errorDetails":details as Any]
						)
					}
				} catch {
					print("Failed to flag as spam!")
					DispatchQueue.main.async {
						NotificationCenter.default.post(
							name: Report.FlagFailedNotification,
							object: self
						)
					}
				}
			}
			
			
		}
	}
}
