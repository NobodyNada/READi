//
//  Post.swift
//  SwiftStack
//
//  Created by FelixSFD on 06.12.16.
//
//

import Foundation

// - MARK: The type of the post

/**
 Defines the type of a post. Either a question or an answer
 
 - author: FelixSFD
 */
public enum PostType: String, StringRepresentable {
    case answer = "answer"
    case question = "question"
}

// - MARK: Post

/**
 The base class of `Question`s and `Answer`s
 
 - author: FelixSFD
 
 - seealso: [StackExchange API](https://api.stackexchange.com/docs/types/post)
 */
public class Post: Content {
    
    // - MARK: Post.Notice
    
    /**
     Represents a notice on a post.
     
     - author: FelixSFD
     */
    public struct Notice: JsonConvertible {
        
        public init?(jsonString json: String) {
            do {
                guard let dictionary = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments) as? [String: Any] else {
                    return nil
                }
                
                self.init(dictionary: dictionary)
            } catch {
                return nil
            }
        }
        
        public init(dictionary: [String: Any]) {
            self.body = dictionary["body"] as? String
            
            if let timestamp = dictionary["creation_date"] as? Int {
                self.creation_date = Date(timeIntervalSince1970: Double(timestamp))
            }
            
            self.owner_user_id = dictionary["owner_user_id"] as? Int
        }
        
        public var dictionary: [String: Any] {
            var dict = [String: Any]()
            
            dict["body"] = body
            dict["creation_date"] = creation_date
            dict["owner_user_id"] = owner_user_id
            
            return dict
        }
        
        public var jsonString: String? {
            return (try? JsonHelper.jsonString(from: self)) ?? nil
        }
        
        
        public var body: String?
        public var creation_date: Date?
        public var owner_user_id: Int?
    }
    
    // - MARK: Initializers
    
    /**
     Basic initializer without default values
     */
    public override init() {
        super.init()
    }
    
    /**
     Initializes the object from a JSON string.
     
     - parameter json: The JSON string returned by the API
     
     - author: FelixSFD
     */
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
        
        self.comment_count = dictionary["comment_count"] as? Int
        
        if let commentsArray = dictionary["comments"] as? [[String: Any]] {
            var commentsTmp = [Comment]()
            
            for commentDictionary in commentsArray {
                let commentTmp = Comment(dictionary: commentDictionary)
                commentsTmp.append(commentTmp)
            }
        }
        
        self.down_vote_count = dictionary["down_vote_count"] as? Int
        self.downvoted = dictionary["downvoted"] as? Bool
        
        if let timestamp = dictionary["last_activity_date"] as? Int {
            self.last_activity_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        if let timestamp = dictionary["last_edit_date"] as? Int {
            self.last_edit_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        if let user = dictionary["last_editor"] as? [String: Any] {
            self.last_editor = User(dictionary: user)
        }
        
        if let urlString = dictionary["share_link"] as? String {
            self.share_link = URL(string: urlString)
        }
        
        self.title = (dictionary["title"] as? String)?.stringByDecodingHTMLEntities
        self.up_vote_count = dictionary["up_vote_count"] as? Int
    }
    
    
    // - MARK: JsonConvertible
    
    public override var dictionary: [String: Any] {
        var dict = super.dictionary
        
        dict["comment_count"] = comment_count
        
        if comments != nil && (comments?.count)! > 0 {
            var tmpComments = [[String: Any]]()
            for comment in comments! {
                tmpComments.append(comment.dictionary)
            }
            
            dict["comments"] = tmpComments
        }
        
        dict["down_vote_count"] = down_vote_count
        dict["downvoted"] = downvoted
        dict["last_activity_date"] = last_activity_date
        dict["last_edit_date"] = last_edit_date
        dict["last_editor"] = last_editor?.dictionary
        dict["share_link"] = share_link
        dict["title"] = title
        dict["up_vote_count"] = up_vote_count
        
        return dict
    }
    
    
    // - MARK: Fields
    
    public var comment_count: Int?
    
    public var comments: [Comment]?
    
    public var down_vote_count: Int?
    
    public var downvoted: Bool?
    
    public var last_activity_date: Date?
    
    public var last_edit_date: Date?
    
    public var last_editor: User?
    
    public var share_link: URL?
    
    public var title: String?
    
    public var up_vote_count: Int?
    
}
