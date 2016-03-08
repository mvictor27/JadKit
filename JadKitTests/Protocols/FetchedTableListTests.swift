//
//  FetchedTableListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/6/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import CoreData
import UIKit
import XCTest

@testable import JadKit

class FetchedTableListTests: JadKitTests {
  private var tableViewController: FetchedTableListViewController!

  private var tableView: UITableView {
    return tableViewController.tableView
  }

  override func setUp() {
    super.setUp()

    tableViewController = FetchedTableListViewController(style: .Plain)
    tableViewController.fetchedResultsController = fetchedResultsController

    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: testReuseIdentifier)

    insertAndSaveObjects(10, sectionName: "First")
    insertAndSaveObjects(5, sectionName: "Second")

    performFetch()
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
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        let cell = tableViewController.tableView(tableView,
          cellForRowAtIndexPath: indexPath)

        if let testObject = tableViewController.objectAtIndexPath(indexPath) {
          XCTAssertEqual(cell.textLabel!.text, testObject.name)
        } else {
          XCTFail()
        }
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

  func testAddingRow() {
    let numRowsBeforeAdd = tableViewController.numberOfRowsInSection(0)
    addAndSaveObject(UIColor.cyanColor(), sectionName: "First")
    XCTAssertEqual(numRowsBeforeAdd + 1, tableViewController.numberOfRowsInSection(0))
  }

  func testUpdatingRow() {
    let updateIndexPath = NSIndexPath(forRow: 0, inSection: 0)

    guard let objectToUpdate = tableViewController.objectAtIndexPath(updateIndexPath)
      as? TestObject else {
        XCTFail()
        return
    }

    XCTAssertNotEqual(objectToUpdate.color, UIColor.cyanColor())

    updateAndSaveObject(forName: objectToUpdate.name) { object in
      object.color = UIColor.cyanColor()
    }

    guard let updatedObject = tableViewController.objectAtIndexPath(updateIndexPath)
      as? TestObject else {
        XCTFail()
        return
    }

    XCTAssertEqual(updatedObject.color, UIColor.cyanColor())
  }

  func testDeletingRow() {
    let numRowsBeforeDelete = tableViewController.numberOfRowsInSection(0)

    guard let objectToDelete = tableViewController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
      as? TestObject else {
        XCTFail()
        return
    }

    deleteAndSaveObject(objectToDelete)
    XCTAssertEqual(numRowsBeforeDelete - 1, tableViewController.numberOfRowsInSection(0))
  }

  func testMovingRow() {
    let numRowsInSectionOneBeforeMove = tableViewController.numberOfRowsInSection(0)
    let numRowsInSectionTwoBeforeMove = tableViewController.numberOfRowsInSection(1)

    guard let objectToMove = tableViewController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
      as? TestObject else {
        XCTFail()
        return
    }

    updateAndSaveObject(forName: objectToMove.name) { object in
      object.sectionName = "Second"
    }

    XCTAssertEqual(numRowsInSectionOneBeforeMove - 1, tableViewController.numberOfRowsInSection(0))
    XCTAssertEqual(numRowsInSectionTwoBeforeMove + 1, tableViewController.numberOfRowsInSection(1))
  }

  func testAddingSection() {
    // TODO: Add a section.
  }

  func testUpdatingSection() {
    // TODO: Figure out how to test updating a section.
  }

  func testDeletingSection() {
    let numSectionsBeforeDelete = tableViewController.numberOfSections
    deleteAndSaveSection("First")
    XCTAssertEqual(numSectionsBeforeDelete - 1, tableViewController.numberOfSections)
  }
}

private class FetchedTableListViewController: UITableViewController, FetchedTableList {
  var fetchedResultsController: NSFetchedResultsController! {
    didSet {
      fetchedResultsController.delegate = self
    }
  }

  var selectedCellIndexPaths = [NSIndexPath]()

  func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
    return testReuseIdentifier
  }

  func listView(listView: UITableView, configureCell cell: UITableViewCell,
    withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
      if let testObject = object as? TestObject {
        cell.textLabel?.text = testObject.name
      }
  }

  func listView(listView: UITableView, didSelectObject object: AnyObject,
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

  // MARK: Fetched Controller

  @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableWillChangeContent()
  }

  @objc func controller(controller: NSFetchedResultsController,
    didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int,
    forChangeType type: NSFetchedResultsChangeType) {
      tableDidChangeSection(sectionIndex, withChangeType: type)
  }

  @objc func controller(controller: NSFetchedResultsController,
    didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
    forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
      tableDidChangeObjectAtIndexPath(indexPath, withChangeType: type, newIndexPath: newIndexPath)
  }

  @objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableDidChangeContent()
  }
}
