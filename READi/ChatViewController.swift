//
//  ChatViewController.swift
//  READi
//
//  Created by Fox Family on 7/17/17.
//  Copyright © 2017 Jonathan Keller. All rights reserved.
//

import UIKit
import WebKit

class ChatViewController: UIViewController {
	var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

		let configuration = WKWebViewConfiguration()

		webView = WKWebView(frame: CGRect.zero, configuration: configuration)
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

		view.addConstraint(NSLayoutConstraint(
			item: webView, attribute: .bottom,
			relatedBy: .equal,
			toItem: bottomLayoutGuide, attribute: .top,
			multiplier: 1, constant: 0
		))
		view.addConstraint(NSLayoutConstraint(
			item: webView, attribute: .leading,
			relatedBy: .equal,
			toItem: view, attribute: .leading,
			multiplier: 1, constant: 0
		))

		webView.load(URLRequest(url: URL(string: "https://chat.stackexchange.com/rooms/11540")!))
    }

	override var preferredStatusBarStyle: UIStatusBarStyle {
		get {
			return .lightContent
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
