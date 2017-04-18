//
//  MasterViewController.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit
import SwiftWebSocket

class MasterViewController: UITableViewController {
	var detailViewController: DetailViewController? = nil
	var cachedReports = [Report]()
	
	var ws = WebSocket()
	private var wsShouldClose = false
	private var lastMessage: Date = Date()
	private var messageTimer: Timer!
	
	func feedbackFailed(notification: NSNotification) {
		if self.view.window != nil {
			let details = notification.userInfo?["errorDetails"] as? String
			self.alert("Failed to send feedback!", details: details)
		}
	}
	
	func flagFailed(notification: NSNotification) {
		if self.view.window != nil {
			let details = notification.userInfo?["errorDetails"] as? String
			self.alert("Failed to flag as spam!", details: details)
		}
	}
	
	
	
	//MARK: - WebSocket
	
	func checkMessage(timer: Timer) {
		if Date.timeIntervalSinceReferenceDate - lastMessage.timeIntervalSinceReferenceDate > 30 {
			ws.close(1002, reason: "no pings for 30 seconds")
			//there's probably a better error code than 1002 (protocol error)
		}
	}
	
	func closeWebsocket() {
		wsShouldClose = true
		messageTimer.invalidate()
		messageTimer = nil
		ws.close()
	}
	
	func openWebsocket() {
		if messageTimer != nil { messageTimer.invalidate() }
		messageTimer = Timer.scheduledTimer(
			timeInterval: 30,
			target: self,
			selector: #selector(checkMessage(timer:)),
			userInfo: nil, repeats: true)
		
		ws.event.open = {
			print("Websocket opened!")
			self.ws.send(text:
				"{\"identifier\": " +
					"\"{\\\"channel\\\":\\\"ApiChannel\\\"," +
					"\\\"key\\\":\\\"\(client.key)\\\"}\"," +
				"\"command\": \"subscribe\"}"
			)
		}
		ws.event.close = {code, reason, clean in
			print("Websocket closed.")
			if !clean && !self.wsShouldClose {
				//attempt to reopen the websocket
				print("Reopening websocket.")
				self.openWebsocket()
			}
		}
		ws.event.error = { error in print(error) }
		
		ws.event.message = {message in
			self.lastMessage = Date()
			guard let text = message as? String else { return }
			print(text)
			guard let json = (try? client.parseJSON(text) as? [String:Any]) ?? nil else { return }
			guard let message = json["message"] as? [String:Any] else { return }
			
			if let feedback = message["feedback"] as? [String:String] {
				self.received(feedback: feedback)
			} else if let report = message["not_flagged"] as? [String:Any] {
				self.received(report: report)
			} else if let report = message["flagged"] as? [String:Any] {
				self.received(report: report)
			}
		}
		
		
		wsShouldClose = false
		ws.open("wss://metasmoke.erwaysoftware.com/cable")
	}
	
	func received(report: [String:Any]) {
		DispatchQueue.main.async {
			self.cachedReports.insert(Report(json: report), at: 0)
			self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
		}
	}
	
	
	func received(feedback: [String:String]) {
		DispatchQueue.global().async {
			do {
				let indices = self.cachedReports.indices.filter { self.cachedReports[$0].link == feedback["post_link"] }
				for index in indices {
					try self.cachedReports[index].fetchFeedback(client: client)
				}
				
				DispatchQueue.main.async {
					self.tableView.reloadRows(
						at: indices.map { IndexPath(row: $0, section: 0) },
						with: .automatic
					)
				}
			} catch {
				print(error)
			}
		}
	}
	
	//MARK: - iOS event handling
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			let navigationController = (controllers[controllers.count-1] as! UINavigationController)
			self.detailViewController = navigationController.topViewController as? DetailViewController
			
		}
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(feedbackFailed(notification:)),
			name: Report.FeedbackFailedNotification,
			object: nil
		)
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(flagFailed(notification:)),
			name: Report.FlagFailedNotification,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(closeWebsocket),
			name: AppDelegate.didEnterBackground,
			object: nil
		)
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(openWebsocket),
			name: AppDelegate.willEnterForeground,
			object: nil
		)
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 200
		
		openWebsocket()
		
		refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func insertNewObject(_ sender: Any) {
		
	}
	
	func refresh(_ sender: Any) {
		print("Refreshing!")
		DispatchQueue.global().async {
			do {
				self.cachedReports = try self.fetchPosts(page: 1, pageSize: 10)
			} catch {
				print(error)
				self.alert("Failed to refresh!")
			}
			
			for report in self.cachedReports {
				DispatchQueue.global().async {
					report.renderAttributedText()
				}
				
				client.queue.async {
					do {
						try report.fetchFeedback(client: client)
						
						guard let index = self.cachedReports.index(where: { report.id == $0.id }) else {
							return
						}
						let indexPath = IndexPath(row: index, section: 0)
						
						DispatchQueue.main.sync {
							self.tableView.reloadRows(at: [indexPath], with: .automatic)
						}
					} catch {
						print(error)
					}
				}
			}
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
				self.refreshControl?.endRefreshing()
			}
		}
	}
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = cachedReports[indexPath.row]
				let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.report = object
				controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
				controller.navigationItem.leftItemsSupplementBackButton = true
			}
		}
	}
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cachedReports.count + 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		let row = indexPath.row
		
		if row == cachedReports.count {
			cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath)
			fetchPosts(start: row)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell", for: indexPath) as! ReportTableViewCell
			
			let postCell = cell as! ReportTableViewCell
			if cachedReports[row].attributedBody == nil {
				cachedReports[row].renderAttributedText()
			}
			postCell.report = cachedReports[row]
			postCell.tableView = tableView
		}
		
		cell.layoutIfNeeded()
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			cachedReports.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let c = cell as? LoadingTableViewCell {
			c.activityIndicator.startAnimating()
		}
	}
	
	
	///MARK: Metasmoke API
	
	func fetchPosts(page: Int, pageSize: Int) throws -> [Report] {
		let response: String = try client.get(
			"https://metasmoke.erwaysoftware.com/api/posts/between" +
				"?from_date=0&to_date=\(Int(Date().timeIntervalSince1970))" +
			"&per_page=\(pageSize)&page=\(page)&key=\(client.key)"
		)
		
		guard let json = try client.parseJSON(response) as? [String:Any] else {
			return []
		}
		
		return Report.from(json: json)
	}
	
	func fetchPosts(start: Int) {
		client.queue.async {
			do {
				let pageSize = 10
				let startPage = start/10 + 1
				let offset = start % 10
				
				var posts = try self.fetchPosts(page: startPage, pageSize: pageSize)[offset..<pageSize]
				
				if offset != 0 {
					posts += try self.fetchPosts(page: startPage + 1, pageSize: pageSize)[0...offset]
				}
				
				print(posts)
				
				DispatchQueue.main.sync {
					self.cachedReports.insert(contentsOf: posts, at: start)
					self.tableView.insertRows(
						at: posts.indices.map { IndexPath(row: start + $0, section: 0) },
						with: .automatic
					)
				}
				
				for post in posts {
					DispatchQueue.global().async {
						post.renderAttributedText()
					}
					
					client.queue.async {
						do {
							
							try post.fetchFeedback(client: client)
							
							guard let index = self.cachedReports.index(where: { post.id == $0.id }) else {
								return
							}
							let indexPath = IndexPath(row: index, section: 0)
							
							DispatchQueue.main.sync {
								self.tableView.reloadRows(at: [indexPath], with: .automatic)
							}
						} catch {
							print(error)
						}
					}
				}
			} catch {
				print(error)
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

