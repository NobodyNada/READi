//
//  Revision.swift
//  SwiftStack
//
//  Created by FelixSFD on 21.12.16.
//
//

import Foundation

/**
 This type represents that state of a `Post` at some point in its history.
 
 - note: We cannot make this a subclass of `Post`, because it does not contain every property of `Post`.
 
 - author: FelixSFD
 
 - seealso: [Stack Exchange API](https://api.stackexchange.com/docs/types/revision)
 */
public class Revision {
    
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
        
        self.comment = (dictionary["comment"] as? String)?.stringByDecodingHTMLEntities
        
        if let timestamp = dictionary["creation_date"] as? Int {
            self.creation_date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        
        self.is_rollback = dictionary["is_rollback"] as? Bool
        
        self.last_body = (dictionary["last_body"] as? String)?.stringByDecodingHTMLEntities
        
        self.last_tags = dictionary["last_tags"] as? [String]
        
        self.last_title = (dictionary["last_title"] as? String)?.stringByDecodingHTMLEntities
        
        self.post_id = dictionary["post_id"] as? Int
        
        if let type = dictionary["post_type"] as? String {
            self.post_type = PostType(rawValue: type)
        }
        
        self.revision_guid = dictionary["revision_guid"] as? String
        
        self.revision_number = dictionary["revision_number"] as? Int
        
        if let type = dictionary["revision_type"] as? String {
            self.revision_type = RevisionType(rawValue: type)
        }
        
        self.set_community_wiki = dictionary["set_community_wiki"] as? Bool
        
        self.tags = dictionary["tags"] as? [String]
        
        self.title = (dictionary["title"] as? String)?.stringByDecodingHTMLEntities
        
        if let user = dictionary["owner"] as? [String: Any] {
            self.user = User(dictionary: user)
        }
    }
    
    // - MARK: Revision type
    
    /**
     The type of the revision. This can either be `single_user` or `vote_based`
     */
    public enum RevisionType: String, StringRepresentable {
        /// A revision of a single user
        case single_user = "single_user"
        
        /// The revision was approved by voting
        case vote_based = "vote_based"
    }
    
    // - MARK: Fields
    
    public var body: String?
    
    public var comment: String?
    
    public var creation_date: Date?
    
    public var is_rollback: Bool?
    
    public var last_body: String?
    
    public var last_tags: [String]?
    
    public var last_title: String?
    
    public var post_id: Int?
    
    public var post_type: PostType?
    
    public var revision_guid: String?
    
    public var revision_number: Int?
    
    public var revision_type: RevisionType?
    
    public var set_community_wiki: Bool?
    
    public var tags: [String]?
    
    public var title: String?
    
    public var user: User?
    
}

extension Revision: JsonConvertible {
    // - MARK: JsonConvertible
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["body"] = body
        dict["comment"] = comment
        dict["creation_date"] = creation_date
        dict["is_rollback"] = is_rollback
        dict["last_body"] = last_body
        dict["last_tags"] = last_tags
        dict["last_title"] = last_title
        dict["post_id"] = post_id
        dict["post_type"] = post_type
        dict["revision_guid"] = revision_guid
        dict["revision_number"] = revision_number
        dict["revision_type"] = revision_type
        dict["set_community_wiki"] = set_community_wiki
        dict["tags"] = tags
        dict["title"] = title
        dict["user"] = user?.dictionary
        
        return dict
    }
    
    public var jsonString: String? {
        return (try? JsonHelper.jsonString(from: self)) ?? nil
    }
}

extension Revision: CustomStringConvertible {
    // - MARK: CustomStringConvertible
    
    public var description: String {
        return "\(dictionary)"
    }
}
