//
//  SuggestedEdit.swift
//  SwiftStack
//
//  Created by FelixSFD on 21.12.16.
//
//

import Foundation

/**
 This type represents a suggested edit on a Stack Exchange site.
 
 - author: FelixSFD
 
 - seealso: [Stack Exchange API](https://api.stackexchange.com/docs/types/suggested-edit)
 */
public class SuggestedEdit {
    
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
        
        if let timestamp = dictionary["approval_date"] as? Int {
            self.approval_date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        
        self.body = (dictionary["body"] as? String)?.stringByDecodingHTMLEntities
        
        self.comment = (dictionary["comment"] as? String)?.stringByDecodingHTMLEntities
        
        if let timestamp = dictionary["creation_date"] as? Int {
            self.creation_date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        
        self.post_id = dictionary["post_id"] as? Int
        
        if let type = dictionary["post_type"] as? String {
            self.post_type = PostType(rawValue: type)
        }
        
        if let user = dictionary["owner"] as? [String: Any] {
            self.proposing_user = User(dictionary: user)
        }
        
        if let timestamp = dictionary["rejection_date"] as? Int {
            self.rejection_date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        
        self.suggested_edit_id = dictionary["suggested_edit_id"] as? Int
        
        self.tags = dictionary["tags"] as? [String]
        
        self.title = (dictionary["title"] as? String)?.stringByDecodingHTMLEntities
    }
    
    // - MARK: Fields
    
    public var approval_date: Date?
    
    public var body: String?
    
    public var comment: String?
    
    public var creation_date: Date?
    
    public var post_id: Int?
    
    public var post_type: PostType?
    
    public var proposing_user: User?
    
    public var rejection_date: Date?
    
    public var suggested_edit_id: Int?
    
    public var tags: [String]?
    
    public var title: String?
    
}


extension SuggestedEdit: JsonConvertible {
    // - MARK: JsonConvertible
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["approval_date"] = approval_date
        dict["body"] = body
        dict["comment"] = comment
        dict["creation_date"] = creation_date
        dict["post_id"] = post_id
        dict["post_type"] = post_type
        dict["proposing_user"] = proposing_user?.dictionary
        dict["rejection_date"] = rejection_date
        dict["suggested_edit_id"] = suggested_edit_id
        dict["tags"] = tags
        dict["title"] = title
        
        return dict
    }
    
    public var jsonString: String? {
        return (try? JsonHelper.jsonString(from: self)) ?? nil
    }
}

extension SuggestedEdit: CustomStringConvertible {
    // - MARK: CustomStringConvertible
    
    public var description: String {
        return "\(dictionary)"
    }
}
