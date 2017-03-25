//
//  BadgeCount.swift
//  SwiftStack
//
//  Created by FelixSFD on 03.12.16.
//
//

import Foundation

/**
 Represents the numbers of gold, silver and bronze badges a `User` has.
 
 - author: FelixSFD
 
 - seealso: [StackExchage API](https://api.stackexchange.com/docs/types/badge-count)
 */
public struct BadgeCount: JsonConvertible, CustomStringConvertible {
    public var bronze: Int?
    public var silver: Int?
    public var gold: Int?
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        dict["bronze"] = bronze ?? nil
        dict["silver"] = silver ?? nil
        dict["gold"] = gold ?? nil
        
        return dict
    }
    
    public var jsonString: String? {
        return (try? JsonHelper.jsonString(from: self)) ?? nil
    }
    
    public var description: String {
        return "\(dictionary)"
    }
    
    // - MARK: Initializers
    
    /**
     Basic initializer with 0 as default values.
     */
    public init() {
        bronze = 0
        silver = 0
        gold = 0
    }
    
    /**
     Initializes the struct with the number of badges.
     */
    public init(gold: Int, silver: Int, bronze: Int) {
        self.bronze = bronze
        self.silver = silver
        self.gold = gold
    }
    
    /**
     Initializes the struct from a JSON-string.
     
     - author: FelixSFD
     */
    public init?(jsonString json: String) {
        do {
            guard let dictionary = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments) as? [String: Any] else {
                return nil
            }
            
            self.bronze = dictionary["bronze"] as? Int
            self.silver = dictionary["silver"] as? Int
            self.gold = dictionary["gold"] as? Int
            
            if bronze == nil, silver == nil, gold == nil {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    /**
     Initializes the struct from a `Dictionary<String: Any>`
     
     - author: FelixSFD
     */
    public init(dictionary: [String: Any]) {
        self.bronze = dictionary["bronze"] as? Int
        self.silver = dictionary["silver"] as? Int
        self.gold = dictionary["gold"] as? Int
    }
}
