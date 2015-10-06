//
//  Date.swift
//  JadKit
//
//  Created by Jad Osseiran on 6/10/2015.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import Foundation

private func <(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == .OrderedAscending
}

private func ==(lhs: NSDate, rhs: NSDate) -> Bool {
  return lhs.compare(rhs) == .OrderedSame
}
