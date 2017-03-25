//
//  JsonConvertible.swift
//  SwiftStack
//
//  Created by FelixSFD on 06.12.16.
//
//

import Foundation

/**
 Objects that can be created fom a JSON-string or be converted to one, conform to this protocol.
 
 The used datatypes should be in the format as returned from the StackExchange API. (for example `Date` as UNIX timestamp)
 
 - note: This protocol inherits from `DictionaryConvertible`
 
 - author: FelixSFD
 */
public protocol JsonConvertible: DictionaryConvertible {
    /**
     Initializes the object from a JSON-string
     */
    init?(jsonString json: String)
    
    /**
     Returns the JSON-representation of the object
     */
    var jsonString: String? { get }
}
