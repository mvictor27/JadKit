//
//  FetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/13/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import Foundation
import CoreData

@objc public protocol FetchedList: List, NSFetchedResultsControllerDelegate {
    var fetchedResultsController: NSFetchedResultsController! { get set }
}

public extension FetchedList {
    func numberOfSections() -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if let sections = fetchedResultsController?.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        let numSections = numberOfSections()
        let validSection = indexPath.section < numSections && indexPath.section >= 0
        
        let numRows = numberOfRowsInSection(indexPath.section)
        let validRow = indexPath.row < numRows && indexPath.row >= 0
        
        return validSection && validRow
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if isValidIndexPath(indexPath) == false {
            return nil
        }
        return fetchedResultsController?.objectAtIndexPath(indexPath)
    }
    
    func sectionIndexTitles() -> [AnyObject]? {
        return fetchedResultsController?.sectionIndexTitles
    }
    
    func sectionForSectionIndexTitle(title: String, atIndex index: Int) -> Int? {
        return fetchedResultsController?.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        let section = fetchedResultsController?.sections?[section]
        return section?.name
    }
}

// MARK: - Table

@objc public protocol TableFetchedList: FetchedList, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView! { get set }
    
    func updateTableCell(cell: UITableViewCell, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath)
}

/**
UITableViewDelegate / UITableViewDataSource
*/
public extension TableFetchedList {
    func tableCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if let object = objectAtIndexPath(indexPath) {
            listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    func tableDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        if let object = objectAtIndexPath(indexPath) {
            listView(tableView, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

/**
NSFetchedResultsControllerDelegate
*/
public extension TableFetchedList {
    func tableWillChangeContent() {
        tableView.beginUpdates()
    }
    
    func tableDidChangeSection(sectionIndex: Int, withChangeType type: NSFetchedResultsChangeType){
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func tableDidChangeObjectAtIndexPath(indexPath: NSIndexPath?, withChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath!)
                updateTableCell(cell, withObject: object, atIndexPath: indexPath!)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    func tableDidChangeContent() {
        tableView.endUpdates()
    }
}

// MARK: - Collection

@objc public protocol CollectionFetchedList: FetchedList, UICollectionViewDataSource, UICollectionViewDelegate {
    /// The collection view to update with the fetched changes.
    var collectionView: UICollectionView! { get set }
    
    /// Classes that conform to this protol only to initialize this property.
    /// It is an array of block operations used to hold the section and row changes so that
    /// the collection view can be animated in the same way a table view controller
    /// handles section changes.
    var changeOperations: [NSBlockOperation] { get set }
    
    func updateCollectionCell(cell: UICollectionViewCell, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath)
}

/**
Custom behaviour
*/
public extension CollectionFetchedList {
    func cancelCollectionViewChangeOperations() {
        for operation: NSBlockOperation in changeOperations {
            operation.cancel()
        }
        changeOperations.removeAll(keepCapacity: false)
    }
}

/**
UICollectionViewDelegate / UICollectionViewDataSource
*/
public extension CollectionFetchedList {
    func collectionCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        if let object = objectAtIndexPath(indexPath) {
            listView(collectionView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
        if let object = objectAtIndexPath(indexPath) {
            listView(collectionView, didSelectObject: object, atIndexPath: indexPath)
        }
    }
}

/**
NSFetchedResultsControllerDelegate
*/
public extension CollectionFetchedList {
    func collectionDidChangeSection(sectionIndex: Int, withChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.insertSections(NSIndexSet(index: sectionIndex))
                    }
                }
            )
        case .Update:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.reloadSections(NSIndexSet(index: sectionIndex))
                    }
                }
            )
        case .Delete:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.deleteSections(NSIndexSet(index: sectionIndex))
                    }
                }
            )
        default:
            break
        }
    }
    
    func collectionDidChangeObjectAtIndexPath(indexPath: NSIndexPath?, withChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.insertItemsAtIndexPaths([newIndexPath!])
                    }
                }
            )
        case .Update:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.reloadItemsAtIndexPaths([indexPath!])
                    }
                }
            )
        case .Move:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
                    }
                }
            )
        case .Delete:
            changeOperations.append(
                NSBlockOperation { [weak self] in
                    if let weakSelf = self {
                        weakSelf.collectionView.deleteItemsAtIndexPaths([indexPath!])
                    }
                }
            )
        }
    }
    
    func collectionDidChangeContent() {
        collectionView.performBatchUpdates({
            for operation in self.changeOperations {
                operation.start()
            }
        }, completion: { finished in
            self.changeOperations.removeAll(keepCapacity: false)
        })
    }
}

// MARK: Private methods to deal with Objective-C's dinosaur's behaviours.

private extension NSNumber {
    convenience init(changeType: NSFetchedResultsChangeType) {
        self.init(unsignedLong: changeType.rawValue)
    }
}
