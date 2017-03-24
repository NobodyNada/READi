//
//  MasterViewController.swift
//  READY
//
//  Created by NobodyNada on 3/21/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
	var detailViewController: DetailViewController? = nil
	var cachedPosts = [Post]()
	
	func feedbackFailed(notification: NSNotification) {
		if self.view.window != nil {
			let details = notification.userInfo?["errorDetails"] as? String
			self.alert("Failed to send feedback!", details: details)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let split = self.splitViewController {
			let controllers = split.viewControllers
			let navigationController = (controllers[controllers.count-1] as! UINavigationController)
			self.detailViewController = navigationController.topViewController as? DetailViewController
			
		}
		
		
		
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(feedbackFailed(notification:)),
			name: Post.FeedbackFailedNotification,
			object: nil
		)
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 200
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
	
	// MARK: - Segues
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
			if let indexPath = self.tableView.indexPathForSelectedRow {
				let object = cachedPosts[indexPath.row]
				let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.post = object
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
		return cachedPosts.count + 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		let row = indexPath.row
		
		if row == cachedPosts.count {
			cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath)
			fetchPosts(start: row)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
			
			let postCell = cell as! PostTableViewCell
			postCell.post = cachedPosts[row]
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return false
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			cachedPosts.remove(at: indexPath.row)
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
	
	func fetchPosts(page: Int, pageSize: Int) throws -> [Post] {
		let response: String = try client.get(
			"https://metasmoke.erwaysoftware.com/api/posts/between" +
				"?from_date=0&to_date=\(Int(Date().timeIntervalSince1970))" +
			"&per_page=\(pageSize)&page=\(page)&key=\(client.key)"
		)
		
		guard let json = try client.parseJSON(response) as? [String:Any] else {
			return []
		}
		
		return Post.from(json: json)
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
					self.cachedPosts.insert(contentsOf: posts, at: start)
					self.tableView.insertRows(
						at: posts.indices.map { IndexPath(row: start + $0, section: 0) },
						with: .automatic
					)
				}
				
				for post in posts {
					client.queue.async {
						do {
							try post.fetchFeedback(client: client)
							
							guard let index = self.cachedPosts.index(where: { post.id == $0.id }) else {
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

