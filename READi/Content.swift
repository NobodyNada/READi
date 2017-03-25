//
//  Content.swift
//  SwiftStack
//
//  Created by FelixSFD on 10.12.16.
//
//

import Foundation

/**
 The superclass of `Post` and `Comment`.
 
 - note: This class is not part of the StackExchange API!
 
 - author: FelixSFD
 */
public class Content: JsonConvertible, CustomStringConvertible {
    
    // - MARK: Initializers
    
    /**
     Basic initializer without default values
     */
    public init() {
        
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
    
    public required init(dictionary: [String : Any]) {
        self.body = (dictionary["body"] as? String)?.stringByDecodingHTMLEntities
        self.body_markdown = (dictionary["body_markdown"] as? String)?.stringByDecodingHTMLEntities
        
        self.can_flag = dictionary["can_flag"] as? Bool
        
        if let urlString = dictionary["link"] as? String {
            self.link = URL(string: urlString)
        }
        
        if let user = dictionary["owner"] as? [String: Any] {
            self.owner = User(dictionary: user)
        }
        
        self.post_id = dictionary["post_id"] as? Int
        
        if let type = dictionary["post_type"] as? String {
            self.post_type = PostType(rawValue: type)
        }
        
        self.score = dictionary["score"] as? Int
        
        self.upvoted = dictionary["upvoted"] as? Bool
    }
    
    // - MARK: JsonConvertible
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["body"] = body
        dict["body_markdown"] = body_markdown
        dict["can_flag"] = can_flag
        dict["link"] = link
        dict["owner"] = owner?.dictionary
        dict["post_id"] = post_id
        dict["post_type"] = post_type
        dict["score"] = score
        dict["upvoted"] = upvoted
        
        return dict
    }
    
    public var jsonString: String? {
        return (try? JsonHelper.jsonString(from: self)) ?? nil
    }
    
    
    // - MARK: CustomStringConvertible
    
    public var description: String {
        return "\(dictionary)"
    }
    
    
    // - MARK: Fields
    
    public var body: String?
    
    public var body_markdown: String?
    
    public var can_flag: Bool?
    
    public var link: URL?
    
    public var owner: User?
    
    public var post_id: Int?
    
    public var post_type: PostType?
    
    public var score: Int?
    
    public var upvoted: Bool?
    
}
