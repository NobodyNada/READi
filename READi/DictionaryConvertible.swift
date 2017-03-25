//
//  DictionaryConvertible.swift
//  SwiftStack
//
//  Created by FelixSFD on 06.12.16.
//
//

import Foundation

/**
 Objects that can be created fom a dictionary or be converted to one, conform to this protocol.
 
 - author: FelixSFD
 */
public protocol DictionaryConvertible {
    /**
     Initializes the object from a dictionary
     */
    init(dictionary: [String: Any])
    
    /**
     Returns the dictionary-representation of the object
     */
    var dictionary: [String: Any] { get }
}
