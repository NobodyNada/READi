//
//  RootViewController.swift
//  READi
//
//  Created by NobodyNada on 3/23/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class RootViewController: UISplitViewController {
	var authenticationCompletions: [(String?) -> Void] = []
	
	@IBAction func unwindToRoot(seuge: UIStoryboardSegue) {
		
	}
	
	func handleAuthenticationError() {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: "Could not get write token!", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			self.present(alert, animated: true)
			
			self.authenticationCompletions.forEach { $0(nil) }
			self.authenticationCompletions.removeAll()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		
		if authenticationCompletions.isEmpty {
			return
		}
		
		let alert =
			UIAlertController(title: "Enter Token", message: "Enter your authentication token:", preferredStyle: .alert)
		
		let alertCompleted: (UIAlertAction) -> Void = {action in
			var code = alert.textFields?.first?.text
			if code?.isEmpty ?? false { code = nil }
			
			DispatchQueue.global(qos: .background).async {
				do {
					if code == nil {
						self.handleAuthenticationError()
						return
					}
					
					let json = try client.parseJSON(
						client.get("https://metasmoke.erwaysoftware.com/oauth/token?key=\(client.key)&code=\(code!)")
					)
					
					let token = (json as? [String:String])?["token"]
					
					self.authenticationCompletions.forEach { $0(token) }
					self.authenticationCompletions.removeAll()
				} catch {
					print(error)
					self.handleAuthenticationError()
				}
				
			}
		}
		
		alert.addTextField()
		alert.addAction(UIAlertAction(title: "Done", style: .default, handler: alertCompleted))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: alertCompleted))
		
		present(alert, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
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
