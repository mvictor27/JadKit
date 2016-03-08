//
//  NonFetchedListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/5/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import UIKit
import XCTest

@testable import JadKit

class NonFetchedListTests: JadKitTests, NonFetchedList {
  typealias ListView = UIView
  typealias Cell = UIView
  typealias Object = TestObject

  func testObjectAtValidIndexPaths() {
    for section in 0..<listData.count {
      for row in 0..<listData[section].count {
        if let object = objectAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
          XCTAssertEqual(object, listData[section][row])
        } else {
          XCTFail()
        }
      }
    }
  }
  
  func testNumberOfRowsAndSetions() {
    XCTAssertEqual(numberOfSections, listData.count)

    for section in 0..<listData.count {
      XCTAssertEqual(numberOfRowsInSection(section), listData[section].count)
    }
  }

  func testValidIndexPath() {
    XCTAssertTrue(isValidIndexPath(NSIndexPath(forRow: 0, inSection: 1)))
  }

  func testInvalidIndexPath() {
    XCTAssertFalse(isValidIndexPath(NSIndexPath(forRow: 1, inSection: 10)))
  }

  func testObjectAtIndexPathSectionTooBig() {
    XCTAssertNil(objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 2)))
  }
  
  func testObjectAtIndexPathSectionTooSmall() {
    XCTAssertNil(objectAtIndexPath(NSIndexPath(forRow: 0, inSection: -1)))
  }

  func testObjectAtIndexPathRowTooBig() {
    XCTAssertNil(objectAtIndexPath(NSIndexPath(forRow: 10, inSection: 0)))
  }

  func testObjectAtIndexPathRowTooSmall() {
    XCTAssertNil(objectAtIndexPath(NSIndexPath(forRow: -1, inSection: 0)))
  }

  // MARK: Conformance

  func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
    return testReuseIdentifier
  }

  func listView(listView: ListView, configureCell cell: Cell, withObject object: Object,
    atIndexPath indexPath: NSIndexPath) { }

  func listView(listView: ListView, didSelectObject object: Object,
    atIndexPath indexPath: NSIndexPath) { }
}
