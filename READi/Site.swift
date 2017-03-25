//
//  Site.swift
//  SwiftStack
//
//  Created by FelixSFD on 10.12.16.
//
//

import Foundation

/**
 This type represents a site in the Stack Exchange network
 
 - author: FelixSFD
 
 - seealso: [StackExchange API](https://api.stackexchange.com/docs/types/site)
 */
public class Site: JsonConvertible, CustomStringConvertible {
    
    // - MARK: Site relations
    
    /**
     This type represents a site that is related in some way to another site
     */
    public struct Related: JsonConvertible, CustomStringConvertible {
        
        // - MARK: Relation type
        
        /**
         The type of relation
         */
        public enum Relation: String, StringRepresentable {
            case parent = "parent"
            case meta = "meta"
            case chat = "chat"
        }
        
        // - MARK: Initializers
        
        public init(dictionary: [String : Any]) {
            self.api_site_parameter = dictionary["api_site_parameter"] as? String
            self.name = dictionary["name"] as? String
            
            if let relation = dictionary["relation"] as? String {
                self.relation = Relation(rawValue: relation)
            }
            
            if let url = dictionary["site_url"] as? String {
                self.site_url = URL(string: url)
            }
        }
        
        public init?(jsonString json: String) {
            do {
                guard let dictionary = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments) as? [String: Any] else {
                    return nil
                }
                
                self.api_site_parameter = dictionary["api_site_parameter"] as? String
                self.name = dictionary["name"] as? String
                
                if let relation = dictionary["relation"] as? String {
                    self.relation = Relation(rawValue: relation)
                }
                
                if let url = dictionary["site_url"] as? String {
                    self.site_url = URL(string: url)
                }
                
                if api_site_parameter == nil, name == nil, relation == nil, site_url == nil {
                    return nil
                }
            } catch {
                return nil
            }
        }
        
        // - MARK: JsonConvertible
        
        public var dictionary: [String: Any] {
            var dict = [String: Any]()
            
            dict["api_site_parameter"] = api_site_parameter ?? nil
            dict["name"] = name ?? nil
            dict["relation"] = relation ?? nil
            dict["site_url"] = site_url ?? nil
            
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
        
        public var api_site_parameter: String?
        
        public var name: String?
        
        public var relation: Relation?
        
        public var site_url: URL?
    }
    
    // - MARK: Site State
    
    /**
     Represents the state of a site.
     */
    public enum State: String, StringRepresentable {
        case normal = "normal"
        case closed_beta = "closed_beta"
        case open_beta = "open_beta"
        case linked_meta = "linked_meta"
    }
    
    // - MARK: Site type
    
    /**
     Represents the type of a site.
     
     - warning: New types [could be added](https://api.stackexchange.com/docs/unsealed-enumerations).
     */
    public enum SiteType: String, StringRepresentable {
        case main_site = "main_site"
        case meta_site = "meta_site"
    }
    
    // - MARK: Styling
    
    /**
     Represents the style of a `Site`.
     */
    public struct Styling: JsonConvertible, CustomStringConvertible {
        
        // - MARK: Initializers
        
        public init(dictionary: [String : Any]) {
            self.link_color = dictionary["link_color"] as? String
            self.tag_background_color = dictionary["tag_background_color"] as? String
            self.tag_foreground_color = dictionary["tag_foreground_color"] as? String
        }
        
        public init?(jsonString json: String) {
            do {
                guard let dictionary = try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments) as? [String: Any] else {
                    return nil
                }
                
                self.link_color = dictionary["link_color"] as? String
                self.tag_background_color = dictionary["tag_background_color"] as? String
                self.tag_foreground_color = dictionary["tag_foreground_color"] as? String
                
                if link_color == nil, tag_background_color == nil, tag_foreground_color == nil {
                    return nil
                }
            } catch {
                return nil
            }
        }
        
        // - MARK: JsonConvertible
        
        public var dictionary: [String: Any] {
            var dict = [String: Any]()
            
            dict["link_color"] = link_color ?? nil
            dict["tag_background_color"] = tag_background_color ?? nil
            dict["tag_foreground_color"] = tag_foreground_color ?? nil
            
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
        
        public var link_color: String?
        
        public var tag_background_color: String?
        
        public var tag_foreground_color: String?
        
    }
    
    // - MARK: Initializers
    
    /**
     Basic initializer without default values
     */
    public init() {
        
    }
    
    public required init(dictionary: [String : Any]) {
        self.aliases = dictionary["aliases"] as? [String]
        self.api_site_parameter = dictionary["api_site_parameter"] as? String
        self.audience = (dictionary["audience"] as? String)?.stringByDecodingHTMLEntities
        
        if let timestamp = dictionary["closed_beta_date"] as? Int {
            self.closed_beta_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        if let url = dictionary["favicon_url"] as? String {
            self.favicon_url = URL(string: url)
        }
        
        if let url = dictionary["high_resolution_icon_url"] as? String {
            self.high_resolution_icon_url = URL(string: url)
        }
        
        if let url = dictionary["icon_url"] as? String {
            self.icon_url = URL(string: url)
        }
        
        if let timestamp = dictionary["launch_date"] as? Double {
            self.launch_date = Date(timeIntervalSince1970: timestamp)
        }
        
        if let url = dictionary["logo_url"] as? String {
            self.logo_url = URL(string: url)
        }
        
        self.markdown_extensions = dictionary["markdown_extensions"] as? [String]
        self.name = (dictionary["name"] as? String)?.stringByDecodingHTMLEntities
        
        if let timestamp = dictionary["open_beta_date"] as? Int {
            self.open_beta_date = Date(timeIntervalSince1970: Double(timestamp))
        }
        
        if let relatedSites = dictionary["related_sites"] as? [[String: Any]] {
            var relatedArray = [Related]()
            
            for related in relatedSites {
                relatedArray.append(Related(dictionary: related))
            }
            
            if relatedArray.count > 0 {
                self.related_sites = relatedArray
            }
        }
        
        if let state = dictionary["site_state"] as? String {
            self.site_state = State(rawValue: state)
        }
        
        if let type = dictionary["site_type"] as? String {
            self.site_type = SiteType(rawValue: type)
        }
        
        if let url = dictionary["site_url"] as? String {
            self.site_url = URL(string: url)
        }
        
        if let styling = dictionary["styling"] as? [String: Any] {
            self.styling = Styling(dictionary: styling)
        }
        
        self.twitter_account = (dictionary["twitter_account"] as? String)?.stringByDecodingHTMLEntities
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
    
    
    // - MARK: JsonConverible
    
    public var dictionary: [String: Any] {
        var dict = [String: Any]()
        
        if aliases != nil && (aliases?.count)! > 0 {
            dict["aliases"] = aliases
        }
        
        dict["api_site_parameter"] = api_site_parameter
        dict["audience"] = audience
        dict["closed_beta_date"] = closed_beta_date
        dict["favicon_url"] = favicon_url
        dict["high_resolution_icon_url"] = high_resolution_icon_url
        dict["icon_url"] = icon_url
        dict["launch_date"] = launch_date
        dict["logo_url"] = logo_url
        dict["markdown_extensions"] = markdown_extensions
        dict["name"] = name
        dict["open_beta_date"] = open_beta_date
        
        if related_sites != nil && (related_sites?.count)! > 0 {
            var tmpRelatedArray = [[String: Any]]()
            for related in related_sites! {
                tmpRelatedArray.append(related.dictionary)
            }
            
            dict["related_sites"] = tmpRelatedArray
        }
        
        dict["site_state"] = site_state
        dict["site_type"] = site_type
        dict["site_url"] = site_url
        dict["styling"] = styling?.dictionary
        dict["twitter_account"] = twitter_account
        
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
    
    public var aliases: [String]?
    
    public var api_site_parameter: String?
    
    public var audience: String?
    
    public var closed_beta_date: Date?
    
    public var favicon_url: URL?
    
    public var high_resolution_icon_url: URL?
    
    public var icon_url: URL?
    
    public var launch_date: Date?
    
    public var logo_url: URL?
    
    public var markdown_extensions: [String]?
    
    public var name: String?
    
    public var open_beta_date: Date?
    
    public var related_sites: [Related]?
    
    public var site_state: State?
    
    public var site_type: SiteType?
    
    public var site_url: URL?
    
    public var styling: Styling?
    
    public var twitter_account: String?
    
}
