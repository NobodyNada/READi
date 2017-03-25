//
//  Privilege.swift
//  SwiftStack
//
//  Created by FelixSFD on 14.02.17.
//
//

import Foundation

/**
 Represents a privilege a user may have on a Stack Exchange site.
 
 - author: FelixSFD
 
 - seealso: [StackExchange API](https://api.stackexchange.com/docs/types/privilege)
 */
public class Privilege: JsonConvertible, CustomStringConvertible {
    
    // - MARK: Initializers
    
    /**
     Initializes the object from a JSON string.
     
     - parameter json: The JSON string returned by the API
     
     - author: FelixSFD
     */
    public convenience required init?(jsonString json: String) {
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
        description = (dictionary["description"] as? String)?.stringByDecodingHTMLEntities ?? ""
        reputation = dictionary["reputation"] as? Int
        short_description = (dictionary["short_description"] as? String)?.stringByDecodingHTMLEntities
    }
    
    /**
     Basic initializer without any parameters
     */
    public init() {
        description = ""
    }
    
    
    // - MARK: JsonConvertible
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["description"] = description
        dict["reputation"] = reputation
        dict["short_description"] = short_description
        
        return dict
    }
    
    public var jsonString: String? {
        return (try? JsonHelper.jsonString(from: self)) ?? nil
    }
    
    
    // - MARK: Values returned from API
    
    /**
     - note: Not optional due to overlap with the `CustomStringConvertible`-protocol.
     */
    public var description: String
    
    public var reputation: Int?
    
    public var short_description: String?
    
}
