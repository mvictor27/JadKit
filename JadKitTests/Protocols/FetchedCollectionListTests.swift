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
        
        collectionView.register(UICollectionViewCell.self,
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
                let indexPath = IndexPath(row: row, section: section)
                let cell = collectionViewController.collectionView(collectionView,
                                                                   cellForItemAt: indexPath)
                
                if let testObject = collectionViewController.object(at: indexPath) {
                    XCTAssertEqual(cell.backgroundColor, testObject.color)
                } else {
                    XCTFail()
                }
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
                collectionViewController.collectionView(collectionView,
                                                        didSelectItemAt: indexPath)
                XCTAssertTrue(collectionViewController.selectedCellIndexPaths.contains(indexPath))
            }
        }
    }
    
    func testAddingRow() {
        // FIXME: This crashes, it seems like the backing store (fetched results controller) is not
        // updating at the right time and we are getting some NSInternalInconsistency exception.
        // I don't think it is that hard to figure out... just need time.
        //    let numRowsBeforeAdd = collectionViewController.numberOfRows(inSection: 0)
        //    addAndSaveObject(UIColor.cyan, sectionName: "First")
        //    XCTAssertEqual(numRowsBeforeAdd + 1, collectionViewController.numberOfRows(inSection: 0))
    }
    
    func testUpdatingRow() {
        let updateIndexPath = IndexPath(row: 0, section: 0)
        
        guard let objectToUpdate = collectionViewController.object(at: updateIndexPath) else {
            XCTFail()
            return
        }
        
        XCTAssertNotEqual(objectToUpdate.color, UIColor.cyan)
        
        updateAndSaveObject(forName: objectToUpdate.name) { object in
            object.color = UIColor.cyan
        }
        
        guard let updatedObject = collectionViewController.object(at: updateIndexPath) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(updatedObject.color, UIColor.cyan)
    }
    
    func testDeletingRow() {
        let numRowsBeforeDelete = collectionViewController.numberOfRows(inSection: 0)
        
        guard let objectToDelete = collectionViewController.object(at: IndexPath(row: 0, section: 0)) else {
            XCTFail()
            return
        }
        
        deleteAndSaveObject(objectToDelete)
        XCTAssertEqual(numRowsBeforeDelete - 1, collectionViewController.numberOfRows(inSection: 0))
    }
    
    func testMovingRow() {
        let numRowsInSectionOneBeforeMove = collectionViewController.numberOfRows(inSection: 0)
        let numRowsInSectionTwoBeforeMove = collectionViewController.numberOfRows(inSection: 1)
        
        guard let objectToMove = collectionViewController.object(at: IndexPath(row: 0, section: 0)) else {
            XCTFail()
            return
        }
        
        updateAndSaveObject(forName: objectToMove.name) { object in
            object.sectionName = "Second"
        }
        
        XCTAssertEqual(numRowsInSectionOneBeforeMove - 1, collectionViewController.numberOfRows(inSection: 0))
        XCTAssertEqual(numRowsInSectionTwoBeforeMove + 1, collectionViewController.numberOfRows(inSection: 1))
    }
    
    func testAddingSection() {
        // TODO: Add a section.
    }
    
    func testUpdatingSection() {
        // TODO: Figure out how to test updating a section.
    }
    
    func testDeletingSection() {
        let numSectionsBeforeDelete = collectionViewController.numberOfSections
        deleteAndSaveSectionName("First")
        XCTAssertEqual(numSectionsBeforeDelete - 1, collectionViewController.numberOfSections)
    }
}

private class FetchedCollectionListViewController: UICollectionViewController,
                                                   FetchedCollectionList {
  
    
    
    var changeOperations: [BlockOperation] = []
    
    
    var fetchedResultsController: NSFetchedResultsController<TestObject>! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    
    var selectedCellIndexPaths = [IndexPath]()
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return testReuseIdentifier
    }
    
    func listView(_ listView: UICollectionView, configure cell: UICollectionViewCell,
                  with anObject: TestObject, at indexPath: IndexPath) {
       // if let testObject = anObject as? TestObject {
            cell.backgroundColor = anObject.color
       // }
    }
    
    func listView(_ listView: UICollectionView, didSelect anObject: TestObject,
                  at indexPath: IndexPath) {
        selectedCellIndexPaths.append(indexPath)
    }
    
    // MARK: Collection View
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionCell(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        collectionDidSelectItem(at: indexPath)
    }
    
    // MARK: Fetched Controller
    
    @objc func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionWillChangeContent()
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        collectionDidChangeSection(sectionIndex: sectionIndex, withChangeType: type)
    }
    
    @objc func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionDidChangeObject(at: indexPath, withChangeType: type,
                                  newIndexPath: newIndexPath)
    }
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionDidChangeContent()
    }
}
