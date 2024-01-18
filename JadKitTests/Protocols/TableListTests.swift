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

      tableViewController = TableListViewController(style: .plain)
    tableViewController.listData = listData

      tableView.register(UITableViewCell.self, forCellReuseIdentifier: testReuseIdentifier)
  }

  override func tearDown() {
    // Make sure our list controller and view are always in sync.
    testListRowsAndSections()

    super.tearDown()
  }

  func testListRowsAndSections() {
    XCTAssertEqual(tableView.numberOfSections, tableViewController.numberOfSections)

    for section in 0..<tableView.numberOfSections {
      XCTAssertEqual(tableView.numberOfRows(inSection: section),
        tableViewController.numberOfRows(inSection: section))
    }
  }

  func testDequeueCells() {
    // Mimic-ish what a UITableViewController would do
    for section in 0..<tableViewController.numberOfSections(in: tableView) {
      for row in 0..<tableViewController.tableView(tableView, numberOfRowsInSection: section) {
        let cell = tableViewController.tableView(tableView,
          cellForRowAt: IndexPath(row: row, section: section))
        
        // Make sure that through the protocol extensions we didn't mess up the ordering.
        XCTAssertEqual(cell.textLabel!.text, listData[section][row].name)
      }
    }
  }

  func testSelectCells() {
    // Mimic-ish what a UITableViewController would do
    for section in 0..<tableViewController.numberOfSections(in: tableView) {
      for row in 0..<tableViewController.tableView(tableView, numberOfRowsInSection: section) {
        let indexPath = IndexPath(row: row, section: section)

        XCTAssertFalse(tableViewController.selectedCellIndexPaths.contains(indexPath))
        tableViewController.tableView(tableView, didSelectRowAt: indexPath)
        XCTAssertTrue(tableViewController.selectedCellIndexPaths.contains(indexPath))
      }
    }
  }
}

private class TableListViewController: UITableViewController, TableList {
    var listData: [[TestObject]]!
    var selectedCellIndexPaths = [IndexPath]()
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return testReuseIdentifier
    }
    
    func listView(_ listView: UITableView, configure cell: UITableViewCell,
                  with anObject: TestObject, at indexPath: IndexPath) {
        cell.textLabel?.text = anObject.name
    }
    
    func listView(_ listView: UITableView, didSelect anObject: TestObject,
                  at indexPath: IndexPath) {
        selectedCellIndexPaths.append(indexPath)
    }
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        return tableCell(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableDidSelectItem(at: indexPath)
    }
}
