//
//  ChatViewController.swift
//  READi
//
//  Created by Fox Family on 7/17/17.
//  Copyright © 2017 Jonathan Keller. All rights reserved.
//

import UIKit
import WebKit

class ChatViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
	var webView: WKWebView!
	var keyboardShown: Bool = false
	var bottomConstraint: NSLayoutConstraint!
	var userscript: String?

    override func viewDidLoad() {
        super.viewDidLoad()

		// Load userscript
		userscript = try! String.init(contentsOf: Bundle.main.url(forResource: "autoflagging", withExtension: "user.js")!)
		
		let contentController = WKUserContentController()
		contentController.add(self, name: "WebViewControllerMessageHandler")
		
		let configuration = WKWebViewConfiguration()
		configuration.userContentController = contentController

		webView = WKWebView(frame: CGRect.zero, configuration: configuration)
		webView.uiDelegate = self
		webView.navigationDelegate = self
		webView.backgroundColor = UIColor.clear
		webView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(webView)
		view.addConstraint(NSLayoutConstraint(
			item: webView, attribute: .top,
			relatedBy: .equal,
			toItem: topLayoutGuide, attribute: .bottom,
			multiplier: 1, constant: -6
		))
		view.addConstraint(NSLayoutConstraint(
			item: webView, attribute: .trailing,
			relatedBy: .equal,
			toItem: view, attribute: .trailing,
			multiplier: 1, constant: 0
		))

		bottomConstraint = NSLayoutConstraint(
			item: webView, attribute: .bottom,
			relatedBy: .equal,
			toItem: bottomLayoutGuide, attribute: .top,
			multiplier: 1, constant: 0
		);
		view.addConstraint(bottomConstraint);
		view.addConstraint(NSLayoutConstraint(
			item: webView, attribute: .leading,
			relatedBy: .equal,
			toItem: view, attribute: .leading,
			multiplier: 1, constant: 0
		))

		webView.load(URLRequest(url: URL(string: "https://chat.stackexchange.com/rooms/11540")!))
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated);
		
		// Register for keyboard notifications
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated);
		
		// Unregister for keyboard notifications
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		// TODO: prevent strange scrolling
		if keyboardShown {
			return;
		}
		keyboardShown = true;
		
		let userInfo = notification.userInfo!
		let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
		bottomConstraint.constant = -keyboardSize.height;
		UIView.animate(withDuration: userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double) {
			self.view.layoutIfNeeded()
		}
	}

	@objc func keyboardWillHide(notification: NSNotification) {
		if !keyboardShown {
			return;
		}
		keyboardShown = false;
		
		let userInfo = notification.userInfo!
		bottomConstraint.constant = 0;
		UIView.animate(withDuration: userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double) {
			self.view.layoutIfNeeded()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		get {
			return .lightContent
		}
	}
	
	// UIDelegate methods taken from https://gist.github.com/dakeshi/f6bae5e8a6f915581df3

	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (() -> Void)) {
		let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			completionHandler()
		}))
		self.present(alertController, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
			completionHandler(false)
		}))
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
			completionHandler(true)
		}))
		self.present(alertController, animated: true, completion: nil)
	}
	
	//
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript(userscript!) { html, error in
			if error != nil {
				print("Error:", error!)
			} else {
				print("Result:", html ?? "(null)")
			}
		}
	}
	
	// MARK: - WKScriptMessageHandler
	// Not sure if necessary. It would be nice if we could get console.log output here.
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard let body = message.body as? [String: Any] else {
			print("could not convert message body to dictionary: \(message.body)")
			return
		}
		
		guard let type = body["type"] as? String else {
			print("could not convert body[\"type\"] to string: \(body)")
			return
		}
		
		switch type {
		case "outerHTML":
			guard let outerHTML = body["outerHTML"] as? String else {
				print("could not convert body[\"outerHTML\"] to string: \(body)")
				return
			}
			print("outerHTML is \(outerHTML)")
		default:
			print("unknown message type \(type)")
			return
		}
	}
}
