//
//  JsonHelper.swift
//  SwiftStack
//
//  Created by FelixSFD on 08.12.16.
//
//

import Foundation

/**
 An array that only contains objects that can be represented in a JSON string.
 */
public typealias EncodedArray = [Any]

/**
 A dictionary that only contains objects that can be represented in a JSON string.
 */
public typealias EncodedDictionary = [String: Any]

/**
 Helps to convert dictionaries/arrays with custom objects to a valid JSON string. (and back)
 
 - author: FelixSFD
 */
public struct JsonHelper {
    // - MARK: Prepare objects for encoding
    
    /**
     Encodes the contents of a dictionary recursively.
     
     - author: FelixSFD
     */
    public static func encode(object: [String: Any]) -> EncodedDictionary {
        var dict = object
        for key in dict.keys {
            if dict[key] is Date {
                dict[key] = JsonHelper.encode(object: dict[key] as! Date)
            }
            
            if dict[key] is DictionaryConvertible {
                dict[key] = JsonHelper.encode(object: dict[key] as! DictionaryConvertible)
            }
            
            if dict[key] is EncodedArray {
                dict[key] = JsonHelper.encode(object: dict[key] as! EncodedArray)
            }
            
            if dict[key] is EncodedDictionary {
                dict[key] = JsonHelper.encode(object: dict[key] as! EncodedDictionary)
            }
            
            if dict[key] is StringRepresentable {
                dict[key] = JsonHelper.encode(object: dict[key] as! StringRepresentable)
            }
            
            if dict[key] is URL {
                dict[key] = JsonHelper.encode(object: dict[key] as! URL)
            }
        }
        
        return dict
    }
    
    /**
     Encodes the contents of an array recursively.
     
     - author: FelixSFD
     
     - seealso `encode(object: [String: Any])`
     */
    public static func encode(object: [Any]) -> EncodedArray {
        var array = object
        for (index, item) in array.enumerated() {
            if array[index] is Date {
                array[index] = JsonHelper.encode(object: item as! Date)
            }
            
            if array[index] is DictionaryConvertible {
                array[index] = JsonHelper.encode(object: item as! DictionaryConvertible)
            }
            
            if array[index] is EncodedArray {
                array[index] = JsonHelper.encode(object: item as! EncodedArray)
            }
            
            if array[index] is EncodedDictionary {
                array[index] = JsonHelper.encode(object: item as! EncodedDictionary)
            }
            
            if array[index] is StringRepresentable {
                array[index] = JsonHelper.encode(object: item as! StringRepresentable)
            }
            
            if array[index] is URL {
                array[index] = JsonHelper.encode(object: item as! URL)
            }
        }
        
        return array
    }
    
    /**
     Encodes dictionary convertibles like `User`.
     */
    public static func encode(object: DictionaryConvertible) -> EncodedDictionary {
        return JsonHelper.encode(object: object.dictionary)
    }
    
    /**
     Encodes objects that conform to `StringRepresentable`.
     */
    public static func encode(object: StringRepresentable) -> String {
        return object.rawValue
    }
    
    
    /**
     Returns the UNIX timestamp from the `Date`
     */
    public static func encode(object: Date) -> Int {
        return Int(object.timeIntervalSince1970)
    }
    
    /**
     Returns the absolute string of the `URL`.
     */
    public static func encode(object: URL) -> String {
        return object.absoluteString
    }
    
    // - MARK: Encode to JSON-string
    
    /**
     Encodes a `[String: Any]` to a valid JSON-string.
     
     - parameter dictionary: The dictionary to encode
     
     - returns: The JSON-string
     
     - throws: An error if the decoding failed
     
     - author: FelixSFD
     */
    public static func jsonString(from dictionary: [String: Any]) throws -> String? {
        let encoded = JsonHelper.encode(object: dictionary)
        let data = try JSONSerialization.data(withJSONObject: encoded, options: .prettyPrinted)
        
        let string = String(data: data, encoding: .utf8)
        
        return string
    }
    
    /**
     Encodes a `[Any]` to a valid JSON-string.
     
     - parameter array: The array to encode
     
     - returns: The JSON-string
     
     - throws: An error if the decoding failed
     
     - author: FelixSFD
     */
    public static func jsonString(from array: [Any]) throws -> String? {
        let encoded = JsonHelper.encode(object: array)
        let data = try JSONSerialization.data(withJSONObject: encoded, options: .prettyPrinted)
        
        let string = String(data: data, encoding: .utf8)
        
        return string
    }
    
    /**
     Encodes a `DictionaryConvertible` to a valid JSON-string.
     
     - parameter object: The object to encode
     
     - returns: The JSON-string
     
     - throws: An error if the decoding failed
     
     - author: FelixSFD
     */
    public static func jsonString(from object: DictionaryConvertible) throws -> String? {
        let encoded = JsonHelper.encode(object: object)
        let data = try JSONSerialization.data(withJSONObject: encoded, options: .prettyPrinted)
        
        let string = String(data: data, encoding: .utf8)
        
        return string
    }
    
    
    // - MARK: Decode JSON-String
    
    /**
     Decodes a given JSON-string
     
     - note: Unlike the `jsonString(from:)` method, this will not convert the String to custom objects. You will have to use their initializers.
     
     - note: Try to avoid this method. It's easier to use the JSON-initializer of `JsonConvertible` objects.
     
     - parameter json: The JSON-string
     
     - returns: The decoded object
     
     - throws: An error if the decoding failed
     
     - author: FelixSFD
     */
    public static func decode(jsonString json: String) throws -> Any {
        return try JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: .allowFragments)
    }
    
    
}
