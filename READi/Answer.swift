//
//  Answer.swift
//  SwiftStack
//
//  Created by FelixSFD on 09.12.16.
//
//

import Foundation

public class Answer: Post {
    
    // - Initializers
    
    public required init(dictionary: [String : Any]) {
        super.init(dictionary: dictionary)
        
        self.accepted = dictionary["accepted"] as? Bool
        self.answer_id = dictionary["answer_id"] as? Int
        self.post_id = answer_id
        self.awarded_bounty_amount = dictionary["awarded_bounty_amount"] as? Int
        
        if let users = dictionary["awarded_bounty_users"] as? [[String: Any]] {
            var array = [User]()
            
            for user in users {
                let tmpUser = User(dictionary: user)
                array.append(tmpUser)
            }
            
            if array.count > 0 {
                self.awarded_bounty_users = array
            }
        }
        
        if let timestamp = dictionary["community_owned_date"] as? Int {
            self.community_owned_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        if let timestamp = dictionary["creation_date"] as? Int {
            self.creation_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        self.is_accepted = dictionary["is_accepted"] as? Bool
        
        if let timestamp = dictionary["locked_date"] as? Int {
            self.locked_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        self.question_id = dictionary["question_id"] as? Int
        self.tags = dictionary["tags"] as? [String]
    }
    
    public required convenience init?(jsonString json: String) {
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments) as? [String: Any] else {
                return nil
            }
            
            self.init(dictionary: dictionary)
        } catch {
            return nil
        }
    }
    
    // - MARK: Fields
    
    public var accepted: Bool?
    
    public var answer_id: Int?
    
    public var awarded_bounty_amount: Int?
    
    public var awarded_bounty_users: [User]?
    
    public var community_owned_date: Date?
    
    public var creation_date: Date?
    
    public var is_accepted: Bool?
    
    public var locked_date: Date?
    
    public var question_id: Int?
    
    public var tags: [String]?
    
}
