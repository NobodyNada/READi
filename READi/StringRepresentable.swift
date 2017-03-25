//
//  StringRepresentable.swift
//  SwiftStack
//
//  Created by FelixSFD on 08.12.16.
//
//

import Foundation

/**
 Objects that can represented as a `String` conform to this protocol.
 
 - note: This is similar to `RawRepresentable`, but is NOT the same.
 
 - author: FelixSFD
 */
public protocol StringRepresentable {
    var rawValue: String { get }
    init?(rawValue: String)
}
