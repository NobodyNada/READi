//
//  ReportTableViewCell.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit
import DTCoreText

class ReportTableViewCell: UITableViewCell, DTAttributedTextContentViewDelegate {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var bodyLabel: UILabel!
	
	@IBOutlet weak var spamButton: UIButton!
	@IBOutlet weak var vandalismButton: UIButton!
	@IBOutlet weak var naaButton: UIButton!
	@IBOutlet weak var fpButton: UIButton!
	
	var tableView: UITableView!
	
	private var textStorage: NSTextStorage!
	private var textContainer: NSTextContainer!
	var textLayoutManager: NSLayoutManager!
	
	private var needsResize = false
	
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
	
	func layoutFinished() {
		guard needsResize else { return }
		needsResize = false
		
		if textLayoutManager != nil {
			while !textLayoutManager.textContainers.isEmpty {
				textLayoutManager.removeTextContainer(at: 0)
			}
			
			textContainer = NSTextContainer(size: bodyLabel.bounds.size)
			textContainer.lineFragmentPadding = 0
			textContainer.maximumNumberOfLines = bodyLabel.numberOfLines
			textContainer.lineBreakMode = bodyLabel.lineBreakMode
			
			textLayoutManager.addTextContainer(textContainer)
		}
		
		if let body = report.attributedBody {
			body.enumerateAttributes(in: NSRange(0..<body.length)) {attributes, range, stop in
				if let attachment = attributes[NSAttachmentAttributeName] as? GasMaskTextAttachment {
					attachment.width = self.bodyLabel.bounds.width
				}
			}
		}
	}
	
	override func layoutSubviews() {
		bodyLabel.sizeToFit()
		
		super.layoutSubviews()
		
		needsResize = true
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
			
			//draw the plain text temporarily while rendering the HTML asynchronously
			if let text = report.attributedBody {
				bodyLabel.attributedText = text
				textStorage = NSTextStorage(attributedString: text)
				textLayoutManager = NSLayoutManager()
				textStorage.addLayoutManager(textLayoutManager)
			} else {
				bodyLabel.text = report.body
			}
			
			updateFeedback()
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
	
	//MARK: - Touch management
	
	private func clickableElement(at touch: UITouch) -> GasMaskTextAttachment? {
		let location = touch.location(in: bodyLabel)
		let tappedIndex = textLayoutManager.characterIndex(
			for: location,
			in: textContainer,
			fractionOfDistanceBetweenInsertionPoints: nil
		)
		
		var result: GasMaskTextAttachment?
		
		bodyLabel.attributedText?.enumerateAttributes(in: NSRange(location: tappedIndex, length: 1)) {attrs, range, stop in
			if let attachment = attrs[NSAttachmentAttributeName] as? GasMaskTextAttachment? {
				result = attachment
				stop.pointee = true
			}
		}
		
		return result
	}
	
	private var trackedTouches = [UITouch]()
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		var untrackedTouches = Set<UITouch>()
		
		for touch in touches {
			if bodyLabel.bounds.contains(touch.location(in: bodyLabel)) && clickableElement(at: touch) != nil {
				trackedTouches.append(touch)
			} else {
				untrackedTouches.insert(touch)
			}
		}
		
		if !untrackedTouches.isEmpty {
			super.touchesBegan(untrackedTouches, with: event)
		}
	}
	
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		var untrackedTouches = Set<UITouch>()
		
		for touch in touches {
			if trackedTouches.contains(touch) {
				trackedTouches.remove(at: trackedTouches.index(of: touch)!)
				
				if bodyLabel.bounds.contains(touch.location(in: bodyLabel)), let image = clickableElement(at: touch) {
					image.tapped()
					bodyLabel.invalidateIntrinsicContentSize()
					layoutSubviews()
					layoutIfNeeded()
					tableView.beginUpdates()
					tableView.endUpdates()
				}
			} else {
				untrackedTouches.insert(touch)
			}
		}
		
		if !untrackedTouches.isEmpty {
			super.touchesEnded(untrackedTouches, with: event)
		}
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		var untrackedTouches = Set<UITouch>()
		
		for touch in touches {
			if trackedTouches.contains(touch) {
				trackedTouches.remove(at: trackedTouches.index(of: touch)!)
			} else {
				untrackedTouches.insert(touch)
			}
		}
		
		if !untrackedTouches.isEmpty {
			super.touchesCancelled(untrackedTouches, with: event)
		}
	}
	
	
	
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		
		spamButton.tintColor = Feedback.spam.color
		vandalismButton.tintColor = Feedback.vandalism.color
		naaButton.tintColor = Feedback.naa.color
		fpButton.tintColor = Feedback.fp.color
		
		
		
		//bodyLabel.delegate = self
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		layoutFinished()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
