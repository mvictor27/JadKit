//
//  FetchedCollectionListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/6/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import CoreData
import UIKit
import XCTest

@testable import JadKit

class FetchedCollectionListTests: JadKitTests {
  private var collectionViewController: FetchedCollectionListViewController!

  private var collectionView: UICollectionView {
    return collectionViewController.collectionView!
  }

  override func setUp() {
    super.setUp()

    collectionViewController = FetchedCollectionListViewController(
      collectionViewLayout: UICollectionViewFlowLayout())
    collectionViewController.fetchedResultsController = fetchedResultsController

    collectionView.registerClass(UICollectionViewCell.self,
      forCellWithReuseIdentifier: testReuseIdentifier)

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
    XCTAssertEqual(collectionView.numberOfSections(), collectionViewController.numberOfSections)

    for section in 0..<collectionView.numberOfSections() {
      XCTAssertEqual(collectionView.numberOfItemsInSection(section),
        collectionViewController.numberOfRowsInSection(section))
    }
  }

  func testDequeueCells() {
    // Mimic-ish what a UICollectionViewController would do
    for section in 0..<collectionViewController.numberOfSectionsInCollectionView(collectionView) {
      for row in 0..<collectionViewController.collectionView(collectionView,
        numberOfItemsInSection: section) {
          let indexPath = NSIndexPath(forRow: row, inSection: section)
          let cell = collectionViewController.collectionView(collectionView,
            cellForItemAtIndexPath: indexPath)

          if let testObject = collectionViewController.objectAtIndexPath(indexPath) {
            XCTAssertEqual(cell.backgroundColor, testObject.color)
          } else {
            XCTFail()
          }
      }
    }
  }

  func testSelectCells() {
    // Mimic-ish what a UICollectionViewController would do
    for section in 0..<collectionViewController.numberOfSectionsInCollectionView(collectionView) {
      for row in 0..<collectionViewController.collectionView(collectionView,
        numberOfItemsInSection: section) {
          let indexPath = NSIndexPath(forRow: row, inSection: section)

          XCTAssertFalse(collectionViewController.selectedCellIndexPaths.contains(indexPath))
          collectionViewController.collectionView(collectionView,
            didSelectItemAtIndexPath: indexPath)
          XCTAssertTrue(collectionViewController.selectedCellIndexPaths.contains(indexPath))
      }
    }
  }

  func testAddingRow() {
    // FIXME: This crashes, it seems like the backing store (fetched results controller) is not
    // updating at the right time and we are getting some NSInternalInconsistency exception.
    // I don't think it is that hard to figure out... just need time.
//    let numRowsBeforeAdd = collectionViewController.numberOfRowsInSection(0)
//    addAndSaveObject(UIColor.cyanColor(), sectionName: "First")
//    XCTAssertEqual(numRowsBeforeAdd + 1, collectionViewController.numberOfRowsInSection(0))
  }

  func testUpdatingRow() {
    let updateIndexPath = NSIndexPath(forRow: 0, inSection: 0)

    guard let objectToUpdate = collectionViewController.objectAtIndexPath(updateIndexPath)
      as? TestObject else {
        XCTFail()
        return
    }

    XCTAssertNotEqual(objectToUpdate.color, UIColor.cyanColor())

    updateAndSaveObject(forName: objectToUpdate.name) { object in
      object.color = UIColor.cyanColor()
    }

    guard let updatedObject = collectionViewController.objectAtIndexPath(updateIndexPath)
      as? TestObject else {
        XCTFail()
        return
    }

    XCTAssertEqual(updatedObject.color, UIColor.cyanColor())
  }

  func testDeletingRow() {
    let numRowsBeforeDelete = collectionViewController.numberOfRowsInSection(0)

    guard let objectToDelete = collectionViewController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
      as? TestObject else {
        XCTFail()
        return
    }

    deleteAndSaveObject(objectToDelete)
    XCTAssertEqual(numRowsBeforeDelete - 1, collectionViewController.numberOfRowsInSection(0))
  }

  func testMovingRow() {
    let numRowsInSectionOneBeforeMove = collectionViewController.numberOfRowsInSection(0)
    let numRowsInSectionTwoBeforeMove = collectionViewController.numberOfRowsInSection(1)

    guard let objectToMove = collectionViewController.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
      as? TestObject else {
        XCTFail()
        return
    }

    updateAndSaveObject(forName: objectToMove.name) { object in
      object.sectionName = "Second"
    }

    XCTAssertEqual(numRowsInSectionOneBeforeMove - 1, collectionViewController.numberOfRowsInSection(0))
    XCTAssertEqual(numRowsInSectionTwoBeforeMove + 1, collectionViewController.numberOfRowsInSection(1))
  }

  func testAddingSection() {
    // TODO: Add a section.
  }

  func testUpdatingSection() {
    // TODO: Figure out how to test updating a section.
  }

  func testDeletingSection() {
    let numSectionsBeforeDelete = collectionViewController.numberOfSections
    deleteAndSaveSection("First")
    XCTAssertEqual(numSectionsBeforeDelete - 1, collectionViewController.numberOfSections)
  }
}

private class FetchedCollectionListViewController: UICollectionViewController,
  FetchedCollectionList {
    var changeOperations: [NSBlockOperation] = [NSBlockOperation]()

    var fetchedResultsController: NSFetchedResultsController! {
      didSet {
        fetchedResultsController.delegate = self
      }
    }

    var selectedCellIndexPaths = [NSIndexPath]()

    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
      return testReuseIdentifier
    }

    func listView(listView: UICollectionView, configureCell cell: UICollectionViewCell,
      withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        if let testObject = object as? TestObject {
          cell.backgroundColor = testObject.color
        }
    }

    func listView(listView: UICollectionView, didSelectObject object: AnyObject,
      atIndexPath indexPath: NSIndexPath) {
        selectedCellIndexPaths.append(indexPath)
    }

    // MARK: Collection View

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
      return numberOfSections
    }

    override func collectionView(collectionView: UICollectionView,
      numberOfItemsInSection section: Int) -> Int {
        return numberOfRowsInSection(section)
    }

    override func collectionView(collectionView: UICollectionView,
      cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionCellAtIndexPath(indexPath)
    }

    override func collectionView(collectionView: UICollectionView,
      didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionDidSelectItemAtIndexPath(indexPath)
    }

    // MARK: Fetched Controller

    @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
      collectionWillChangeContent()
    }

    @objc func controller(controller: NSFetchedResultsController,
      didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
      atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        collectionDidChangeSection(sectionIndex, withChangeType: type)
    }

    @objc func controller(controller: NSFetchedResultsController,
      didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
      forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        collectionDidChangeObjectAtIndexPath(indexPath, withChangeType: type,
          newIndexPath: newIndexPath)
    }

    @objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
      collectionDidChangeContent()
    }
}
