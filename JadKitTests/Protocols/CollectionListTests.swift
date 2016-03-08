//
//  CollectionListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/4/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import UIKit
import XCTest

@testable import JadKit

class CollectionListTests: JadKitTests {
  private var collectionViewController: CollectionListViewController!

  private var collectionView: UICollectionView {
    return collectionViewController.collectionView!
  }

  override func setUp() {
    super.setUp()

    collectionViewController = CollectionListViewController(
      collectionViewLayout: UICollectionViewFlowLayout())
    collectionViewController.listData = listData

    collectionView.registerClass(UICollectionViewCell.self,
      forCellWithReuseIdentifier: testReuseIdentifier)
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
          let cell = collectionViewController.collectionView(collectionView,
            cellForItemAtIndexPath: NSIndexPath(forRow: row, inSection: section))

          // Make sure that through the protocol extensions we didn't mess up the ordering.
          XCTAssertEqual(cell.backgroundColor, listData[section][row].color)
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
          collectionViewController.collectionView(collectionView, didSelectItemAtIndexPath: indexPath)
          XCTAssertTrue(collectionViewController.selectedCellIndexPaths.contains(indexPath))
      }
    }
  }
}

private class CollectionListViewController: UICollectionViewController, CollectionList {
  var listData: [[TestObject]]!
  var selectedCellIndexPaths = [NSIndexPath]()

  func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
    return testReuseIdentifier
  }

  func listView(listView: UICollectionView, configureCell cell: UICollectionViewCell,
    withObject object: TestObject, atIndexPath indexPath: NSIndexPath) {
      cell.backgroundColor = object.color
  }

  func listView(listView: UICollectionView, didSelectObject object: TestObject,
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
}