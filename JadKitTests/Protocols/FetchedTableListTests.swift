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
        
        tableViewController = FetchedTableListViewController(style: .plain)
        tableViewController.fetchedResultsController = fetchedResultsController
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: testReuseIdentifier)
        
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
            XCTAssertEqual(tableView.numberOfRows(inSection: section),
                           tableViewController.numberOfRows(inSection: section))
        }
    }
    
    func testDequeueCells() {
        // Mimic-ish what a UITableViewController would do
        for section in 0..<tableViewController.numberOfSections(in: tableView) {
            for row in 0..<tableViewController.tableView(tableView, numberOfRowsInSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                let cell = tableViewController.tableView(tableView,
                                                         cellForRowAt: indexPath)
                
                if let testObject = tableViewController.object(at: indexPath) {
                    XCTAssertEqual(cell.textLabel!.text, testObject.name)
                } else {
                    XCTFail()
                }
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
    
    func testAddingRow() {
        let numRowsBeforeAdd = tableViewController.numberOfRows(inSection: 0)
        addAndSaveObject(color: UIColor.cyan, sectionName: "First")
        XCTAssertEqual(numRowsBeforeAdd + 1, tableViewController.numberOfRows(inSection: 0))
    }
    
    func testUpdatingRow() {
        let updateIndexPath = IndexPath(row: 0, section: 0)
        
        guard let objectToUpdate = tableViewController.object(at: updateIndexPath) else {
            XCTFail()
            return
        }
        
        XCTAssertNotEqual(objectToUpdate.color, UIColor.cyan)
        
        updateAndSaveObject(forName: objectToUpdate.name) { object in
            object.color = UIColor.cyan
        }
        
        guard let updatedObject = tableViewController.object(at: updateIndexPath) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(updatedObject.color, UIColor.cyan)
    }
    
    func testDeletingRow() {
        let numRowsBeforeDelete = tableViewController.numberOfRows(inSection: 0)
        
        guard let objectToDelete = tableViewController.object(at: IndexPath(row: 0, section: 0)) else {
            XCTFail()
            return
        }
        
        deleteAndSaveObject(objectToDelete)
        XCTAssertEqual(numRowsBeforeDelete - 1, tableViewController.numberOfRows(inSection: 0))
    }
    
    func testMovingRow() {
        let numRowsInSectionOneBeforeMove = tableViewController.numberOfRows(inSection: 0)
        let numRowsInSectionTwoBeforeMove = tableViewController.numberOfRows(inSection: 1)
        
        guard let objectToMove = tableViewController.object(at: IndexPath(row: 0, section: 0)) else {
            XCTFail()
            return
        }
        
        updateAndSaveObject(forName: objectToMove.name) { object in
            object.sectionName = "Second"
        }
        
        XCTAssertEqual(numRowsInSectionOneBeforeMove - 1, tableViewController.numberOfRows(inSection: 0))
        XCTAssertEqual(numRowsInSectionTwoBeforeMove + 1, tableViewController.numberOfRows(inSection: 1))
    }
    
    func testAddingSection() {
        // TODO: Add a section.
    }
    
    func testUpdatingSection() {
        // TODO: Figure out how to test updating a section.
    }
    
    func testDeletingSection() {
        let numSectionsBeforeDelete = tableViewController.numberOfSections
        deleteAndSaveSectionName("First")
        XCTAssertEqual(numSectionsBeforeDelete - 1, tableViewController.numberOfSections)
    }
}

private class FetchedTableListViewController: UITableViewController, FetchedTableList {
    
    var fetchedResultsController: NSFetchedResultsController<TestObject>! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableCell(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableDidSelectItem(at: indexPath)
    }
    
    // MARK: Fetched Controller
    
    @objc func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableWillChangeContent()
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                          didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int,
                          for type: NSFetchedResultsChangeType) {
        tableDidChangeSection(sectionIndex, withChangeType: type)
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableDidChangeObject(at: indexPath, withChangeType: type, newIndexPath: newIndexPath)
    }
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableDidChangeContent()
    }
}
