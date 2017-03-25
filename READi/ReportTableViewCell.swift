//
//  ReportTableViewCell.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var bodyLabel: UILabel!
	
	@IBOutlet weak var spamButton: UIButton!
	@IBOutlet weak var vandalismButton: UIButton!
	@IBOutlet weak var naaButton: UIButton!
	@IBOutlet weak var fpButton: UIButton!
	
	
	func updateFeedback(notification: NSNotification? = nil) {
		let spamCount = report.feedback?.filter { $0.type == .spam }.count ?? 0
		let vandalismCount = report.feedback?.filter { $0.type == .vandalism }.count ?? 0
		let naaCount = report.feedback?.filter { $0.type == .naa }.count ?? 0
		let fpCount = report.feedback?.filter { $0.type == .fp }.count ?? 0
		
		let buttons = [
			(spamButton!, "spam/rude", spamCount),
			(vandalismButton!, "vandalism", vandalismCount),
			(naaButton!, "naa", naaCount),
			(fpButton!, "fp", fpCount)
		]
		
		for (button, title, count) in buttons {
			let text: String
			if count == 0 {
				text = title
			} else {
				text = "\(title) (\(count))"
			}
			
			button.setTitle(text, for: .normal)
			button.sizeToFit()
		}
	}
	
	
	var report: Report! {
		didSet {
			guard report != nil else { return }
			
			if let old = oldValue {
				NotificationCenter.default.removeObserver(self, name: nil, object: old)
			}
			
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(updateFeedback(notification:)),
				name: Report.FeedbackUpdatedNotification,
				object: report
			)
			
			titleLabel.text = report.title
			
			let htmlData = (report.body +
				"<style>* {font-family: -apple-system; font-size: \(bodyLabel.font.pointSize)px;}</style>"
				).data(using: .utf8)!
			
			bodyLabel.attributedText = (try? NSAttributedString(
				data: htmlData,
				options: [
					NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
					NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
					],
				documentAttributes: nil
			)) ?? NSAttributedString(string: report.body)
			
			updateFeedback()
			
			layoutSubviews()
		}
	}
	
	func feedbackPressed(_ type: Feedback) {
		report.send(feedback: type)
	}
	
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
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		spamButton.tintColor = Feedback.spam.color
		vandalismButton.tintColor = Feedback.vandalism.color
		naaButton.tintColor = Feedback.naa.color
		fpButton.tintColor = Feedback.fp.color
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}