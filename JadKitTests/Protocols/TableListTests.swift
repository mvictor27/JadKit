//
//  TableListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 4/03/2016.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import UIKit
import XCTest

@testable import JadKit

class TableListTests: JadKitTests {
  private var tableViewController: TableListViewController!

  private var tableView: UITableView {
    return tableViewController.tableView
  }

  override func setUp() {
    super.setUp()

    tableViewController = TableListViewController(style: .Plain)
    tableViewController.listData = listData

    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: testReuseIdentifier)
  }

  override func tearDown() {
    // Make sure our list controller and view are always in sync.
    testListRowsAndSections()

    super.tearDown()
  }

  func testListRowsAndSections() {
    XCTAssertEqual(tableView.numberOfSections, tableViewController.numberOfSections)

    for section in 0..<tableView.numberOfSections {
      XCTAssertEqual(tableView.numberOfRowsInSection(section),
        tableViewController.numberOfRowsInSection(section))
    }
  }

  func testDequeueCells() {
    // Mimic-ish what a UITableViewController would do
    for section in 0..<tableViewController.numberOfSectionsInTableView(tableView) {
      for row in 0..<tableViewController.tableView(tableView, numberOfRowsInSection: section) {
        let cell = tableViewController.tableView(tableView,
          cellForRowAtIndexPath: NSIndexPath(forRow: row, inSection: section))
        
        // Make sure that through the protocol extensions we didn't mess up the ordering.
        XCTAssertEqual(cell.textLabel!.text, listData[section][row].name)
      }
    }
  }

  func testSelectCells() {
    // Mimic-ish what a UITableViewController would do
    for section in 0..<tableViewController.numberOfSectionsInTableView(tableView) {
      for row in 0..<tableViewController.tableView(tableView, numberOfRowsInSection: section) {
        let indexPath = NSIndexPath(forRow: row, inSection: section)

        XCTAssertFalse(tableViewController.selectedCellIndexPaths.contains(indexPath))
        tableViewController.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        XCTAssertTrue(tableViewController.selectedCellIndexPaths.contains(indexPath))
      }
    }
  }
}

private class TableListViewController: UITableViewController, TableList {
  var listData: [[TestObject]]!
  var selectedCellIndexPaths = [NSIndexPath]()

  func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
    return testReuseIdentifier
  }

  func listView(listView: UITableView, configureCell cell: UITableViewCell,
    withObject object: TestObject, atIndexPath indexPath: NSIndexPath) {
      cell.textLabel?.text = object.name
  }

  func listView(listView: UITableView, didSelectObject object: TestObject,
    atIndexPath indexPath: NSIndexPath) {
      selectedCellIndexPaths.append(indexPath)
  }

  // MARK: Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return numberOfSections
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRowsInSection(section)
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
      return tableCellAtIndexPath(indexPath)
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableDidSelectItemAtIndexPath(indexPath)
  }
}
