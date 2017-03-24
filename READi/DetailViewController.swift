//
//  DetailViewController.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
	
	@IBOutlet weak var bodyTextView: UITextView!
	@IBOutlet weak var reasonTextView: UITextView!
	
	
	@IBOutlet weak var spamButton: UIButton!
	@IBOutlet weak var vandalismButton: UIButton!
	@IBOutlet weak var naaButton: UIButton!
	@IBOutlet weak var fpButton: UIButton!
	
	@IBAction func spamPressed(_ sender: Any) {
		feedbackPressed(.spam)
	}
	@IBAction func vandalismPressed(_ sender: Any) {
		feedbackPressed(.vandalism)
	}
	@IBAction func naaPressed(_ sender: Any) {
		feedbackPressed(.naa)
		
	}
	@IBAction func fpPressed(_ sender: Any) {
		feedbackPressed(.fp)
	}
	
	func feedbackPressed(_ type: Feedback) {
		post?.send(feedback: type)
	}
	
	
	func updateFeedback(notification: NSNotification? = nil) {
		guard let post = self.post else { return }
		
		let spamCount = post.feedback?.filter { $0.type == .spam }.count ?? 0
		let vandalismCount = post.feedback?.filter { $0.type == .vandalism }.count ?? 0
		let naaCount = post.feedback?.filter { $0.type == .naa }.count ?? 0
		let fpCount = post.feedback?.filter { $0.type == .fp }.count ?? 0
		
		let buttons: [(UIButton?, String, Int)] = [
			(spamButton, "spam/rude", spamCount),
			(vandalismButton, "vandalism", vandalismCount),
			(naaButton, "naa", naaCount),
			(fpButton, "fp", fpCount)
		]
		
		for (button, title, count) in buttons {
			let text: String
			if count == 0 {
				text = title
			} else {
				text = "\(title) (\(count))"
			}
			
			button?.setTitle(text, for: .normal)
			button?.sizeToFit()
		}
	}
	
	func feedbackFailed(notification: NSNotification) {
		guard view.window != nil else { return }
		
		let details = notification.userInfo?["errorDetails"] as? String
		self.alert("Failed to send feedback!", details: details)
	}
	
	
	func configureView() {
		// Update the user interface for the detail item.
		bodyTextView?.layer.borderColor = #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1).cgColor
		reasonTextView?.layer.borderColor = #colorLiteral(red: 0.8374213576, green: 0.8374213576, blue: 0.8374213576, alpha: 1).cgColor
		bodyTextView?.layer.borderWidth = 1
		reasonTextView?.layer.borderWidth = 1
		bodyTextView?.layer.cornerRadius = 2
		reasonTextView?.layer.cornerRadius = 2
		
		spamButton?.tintColor = Feedback.spam.color
		vandalismButton?.tintColor = Feedback.vandalism.color
		naaButton?.tintColor = Feedback.naa.color
		fpButton?.tintColor = Feedback.fp.color
		
		if let post = self.post {
			title = post.title
			bodyTextView?.text = post.body
			reasonTextView?.text = post.why
			
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(updateFeedback(notification:)),
				name: Post.FeedbackUpdatedNotification,
				object: post
			)
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(feedbackFailed(notification:)),
				name: Post.FeedbackUpdatedNotification,
				object: post
			)
			
			
			updateFeedback()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	var post: Post? {
		didSet {
			// Update the view.
			if let old = oldValue {
				NotificationCenter.default.removeObserver(self, name: nil, object: old)
			}
			
			configureView()
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

