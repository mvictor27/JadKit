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
        XCTAssertEqual(numberOfRowsInSection(sectionIndex), sections[sectionIndex].numberOfObjects)
      }
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

  func testValidSectionNames() {
    XCTAssertEqual(titleForHeaderInSection(0), "First")
    XCTAssertEqual(titleForHeaderInSection(1), "Second")
  }

  func testInvalidSectionNames() {
    XCTAssertNil(titleForHeaderInSection(2))
    XCTAssertNil(titleForHeaderInSection(-2))
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
