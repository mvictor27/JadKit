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
        
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: testReuseIdentifier)
    }
    
    override func tearDown() {
        // Make sure our list controller and view are always in sync.
        testListRowsAndSections()
        
        super.tearDown()
    }
    
    func testListRowsAndSections() {
        XCTAssertEqual(collectionView.numberOfSections, collectionViewController.numberOfSections)
        
        for section in 0..<collectionView.numberOfSections {
            XCTAssertEqual(collectionView.numberOfItems(inSection: section),
                           collectionViewController.numberOfRows(inSection: section))
        }
    }
    
    func testDequeueCells() {
        // Mimic-ish what a UICollectionViewController would do
        for section in 0..<collectionViewController.numberOfSections(in: collectionView) {
            for row in 0..<collectionViewController.collectionView(collectionView,
                                                                   numberOfItemsInSection: section) {
                let cell = collectionViewController.collectionView(collectionView,
                                                                   cellForItemAt: IndexPath(row: row, section: section))
                
                // Make sure that through the protocol extensions we didn't mess up the ordering.
                XCTAssertEqual(cell.backgroundColor, listData[section][row].color)
            }
        }
    }
    
    func testSelectCells() {
        // Mimic-ish what a UICollectionViewController would do
        for section in 0..<collectionViewController.numberOfSections(in: collectionView) {
            for row in 0..<collectionViewController.collectionView(collectionView,
                                                                   numberOfItemsInSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                
                XCTAssertFalse(collectionViewController.selectedCellIndexPaths.contains(indexPath))
                collectionViewController.collectionView(collectionView, didSelectItemAt: indexPath)
                XCTAssertTrue(collectionViewController.selectedCellIndexPaths.contains(indexPath))
            }
        }
    }
}

private class CollectionListViewController: UICollectionViewController, CollectionList {

    
    var listData: [[TestObject]]!
    var selectedCellIndexPaths = [IndexPath]()
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return testReuseIdentifier
    }
    
    func listView(_ listView: UICollectionView, configure cell: UICollectionViewCell,
                  with anObject: TestObject, at indexPath: IndexPath) {
        cell.backgroundColor = anObject.color
    }
    
    func listView(_ listView: UICollectionView, didSelect anObject: TestObject,
                  at indexPath: IndexPath) {
        selectedCellIndexPaths.append(indexPath)
    }
    
    
    
    // MARK: Collection View
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionCell(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionDidSelectItem(at: indexPath)
    }
}
