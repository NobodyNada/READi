//
//  Comment.swift
//  SwiftStack
//
//  Created by FelixSFD on 07.12.16.
//
//

import Foundation

/**
 Represents a comment to a `Post`.
 
 - author: FelixSFD
 
 - seealso: [StackExchange API](https://api.stackexchange.com/docs/types/comment)
 */
public class Comment: Content {
    
    // - MARK: Initializers
    
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
    
    public required init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        
        //only initialize the properties that are not part of the superclass
        
        self.comment_id = dictionary["comment_id"] as? Int
        
        if let timestamp = dictionary["creation_date"] as? Int {
            self.creation_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        self.edited = dictionary["edited"] as? Bool
        
        if let user = dictionary["reply_to_user"] as? [String: Any] {
            self.reply_to_user = User(dictionary: user)
        }
    }
    
    // - MARK: JsonConvertible
    
    public override var dictionary: [String: Any] {
        var dict = super.dictionary
        
        dict["comment_id"] = comment_id
        dict["creation_date"] = creation_date
        dict["edited"] = edited
        dict["reply_to_user"] = reply_to_user?.dictionary
        
        return dict
    }
    
    
    // - MARK: Fields
    
    public var comment_id: Int?
    
    public var creation_date: Date?
    
    public var edited: Bool?
    
    public var reply_to_user: User?
    
}
