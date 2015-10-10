//
//  Date.swift
//  JadKit
//
//  Created by Jad Osseiran on 6/10/2015.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import Foundation

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == .OrderedAscending
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return rhs < lhs
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs > rhs) == false
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return (lhs < rhs) == false
}
