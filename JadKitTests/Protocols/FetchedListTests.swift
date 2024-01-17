//
//  FetchedListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/5/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import CoreData
import UIKit
import XCTest

@testable import JadKit

class FetchedListTests: JadKitTests, FetchedList {
  typealias ListView = UIView
  typealias Cell = UIView
  typealias Object = TestObject

  override func setUp() {
    super.setUp()

    insertAndSaveObjects(10, sectionName: "First")
    insertAndSaveObjects(5, sectionName: "Second")

    performFetch()
  }

  func testNumberOfRowsAndSetions() {
    if let sections = fetchedResultsController.sections {
      XCTAssertEqual(numberOfSections, sections.count)

      for sectionIndex in 0..<sections.count {
          XCTAssertEqual(numberOfRows(inSection: sectionIndex), sections[sectionIndex].numberOfObjects)
      }
    }
  }

  func testValidIndexPath() {
    XCTAssertTrue(isValid(IndexPath(row: 0, section: 1)))
  }

  func testInvalidIndexPath() {
    XCTAssertFalse(isValid(IndexPath(row: 1, section: 10)))
  }

  func testObjectAtIndexPathSectionTooBig() {
    XCTAssertNil(object(at: IndexPath(row: 0, section: 2)))
  }

  func testObjectAtIndexPathSectionTooSmall() {
    XCTAssertNil(object(at: IndexPath(row: 0, section: -1)))
  }

  func testObjectAtIndexPathRowTooBig() {
    XCTAssertNil(object(at: IndexPath(row: 10, section: 0)))
  }

  func testObjectAtIndexPathRowTooSmall() {
    XCTAssertNil(object(at: IndexPath(row: -1, section: 0)))
  }

  func testValidSectionNames() {
      XCTAssertEqual(titleForHeaderInSection(section: 0), "First")
      XCTAssertEqual(titleForHeaderInSection(section: 1), "Second")
  }

  func testInvalidSectionNames() {
      XCTAssertNil(titleForHeaderInSection(section: 2))
      XCTAssertNil(titleForHeaderInSection(section: -2))
  }

  // MARK: Conformance

  func cellIdentifier(for indexPath: IndexPath) -> String {
    return testReuseIdentifier
  }

  func listView(_ listView: ListView, configure cell: Cell, with anObject: Object,
    at indexPath: IndexPath) { }

  func listView(_ listView: ListView, didSelect anObject: Object,
    at indexPath: IndexPath) { }
}
