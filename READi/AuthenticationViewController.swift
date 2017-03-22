//
//  WebViewController.swift
//  READi
//
//  Created by NobodyNada on 3/22/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit
import WebKit

class AuthenticationViewController: UIViewController, WKUIDelegate {
	@IBOutlet weak var webViewContainer: UIView!
	
	var webView: WKWebView!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let configuration = WKWebViewConfiguration()
		webView = WKWebView(frame: .zero, configuration: configuration)
		webView.uiDelegate = self
		webView.frame = webViewContainer.bounds
		webViewContainer.addSubview(webView)
		
		webView.load(
			URLRequest(url:
				URL(
					string: "https://metasmoke.erwaysoftware.com/oauth/request?key=\(client.key)"
					)!
			)
		)
	}
	
	override func viewDidLayoutSubviews() {
		webView.frame = webViewContainer.bounds
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: {context in
			self.webView.frame = self.webViewContainer.bounds
		})
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
