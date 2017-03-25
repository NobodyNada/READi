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
		report?.flag()
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
		report?.send(feedback: type)
	}
	
	
	func updateFeedback(notification: NSNotification? = nil) {
		guard let report = self.report else { return }
		
		let spamCount = report.feedback?.filter { $0.type == .spam }.count ?? 0
		let vandalismCount = report.feedback?.filter { $0.type == .vandalism }.count ?? 0
		let naaCount = report.feedback?.filter { $0.type == .naa }.count ?? 0
		let fpCount = report.feedback?.filter { $0.type == .fp }.count ?? 0
		
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
	
	func flagFailed(notification: NSNotification) {
		guard view.window != nil else { return }
		
		let details = notification.userInfo?["errorDetails"] as? String
		self.alert("Failed to flag as spam!", details: details)
	}
	
	override func viewWillLayoutSubviews() {
		bodyTextView.sizeToFit()
		reasonTextView.sizeToFit()
	}
	
	func configureView() {
		// Update the user interface for the detail item.
		
		spamButton?.tintColor = Feedback.spam.color
		vandalismButton?.tintColor = Feedback.vandalism.color
		naaButton?.tintColor = Feedback.naa.color
		fpButton?.tintColor = Feedback.fp.color
		
		if let report = self.report {
			title = report.title
			bodyTextView?.text = report.body
			reasonTextView?.text = report.why
			
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(updateFeedback(notification:)),
				name: Report.FeedbackUpdatedNotification,
				object: report
			)
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(feedbackFailed(notification:)),
				name: Report.FeedbackFailedNotification,
				object: report
			)
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(flagFailed(notification:)),
				name: Report.FlagFailedNotification,
				object: report
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
	
	var report: Report? {
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

