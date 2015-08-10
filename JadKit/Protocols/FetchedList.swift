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
    func numberOfSection() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let section = sections[section] as NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
        return 0
    }
    
    func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        let numSections = numberOfSection()
        let validSection = indexPath.section < numSections && indexPath.section >= 0
        
        let numRows = numberOfRowsInSection(indexPath.section)
        let validRow = indexPath.row < numRows && indexPath.row >= 0
        
        return validSection && validRow
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if isValidIndexPath(indexPath) == false {
            return nil
        }
        return fetchedResultsController.objectAtIndexPath(indexPath)
    }
    
    func sectionIndexTitles() -> [AnyObject]! {
        return fetchedResultsController.sectionIndexTitles
    }
    
    func sectionForSectionIndexTitle(title: String, atIndex index: Int) -> Int {
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    func titleForHeaderInSection(section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let section = sections[section] as NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
        return section?.name
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        listView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
}

/**
NSFetchedResultsControllerDelegate
*/
public extension TableFetchedList {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

// MARK: - Collection

@objc public protocol CollectionFetchedList: FetchedList, UICollectionViewDataSource, UICollectionViewDelegate {
    var collectionView: UICollectionView! { get set }
    
    /// Dictionary is of type: [NSFetchedResultsChangeType: Int]
    var sectionChanges: [NSMutableDictionary] { get set }
    
    /// Dictionary of of type [NSFetchedResultsChangeType: [NSIndexPath]]
    var itemChanges: [NSMutableDictionary] { get set }
    
    func updateCollectionCell(cell: UICollectionViewCell, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath)
}

/**
UICollectionViewDelegate / UICollectionViewDataSource
*/
public extension CollectionFetchedList {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        listView(collectionView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = fetchedResultsController.objectAtIndexPath(indexPath)
        listView(collectionView, didSelectObject: object, atIndexPath: indexPath)
    }
}

/**
NSFetchedResultsControllerDelegate
*/
public extension CollectionFetchedList {
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        let change = NSMutableDictionary()
        change[NSNumber(changeType: type)] = NSNumber(integer: sectionIndex)
        sectionChanges += [change]
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let change = NSMutableDictionary()
        switch type {
        case .Insert:
            change[NSNumber(changeType: type)] = [newIndexPath!]
        case .Delete:
            change[NSNumber(changeType: type)] = [indexPath!]
        case .Update:
            change[NSNumber(changeType: type)] = [indexPath!]
        case .Move:
            change[NSNumber(changeType: type)] = [indexPath!, newIndexPath!]
        }
        itemChanges += [change]
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({
            for sectionChange in self.sectionChanges {
                for (type, section) in sectionChange {
                    switch type as! NSFetchedResultsChangeType {
                    case .Insert:
                        self.collectionView?.insertSections(NSIndexSet(index: section as! Int))
                    case .Delete:
                        self.collectionView?.deleteSections(NSIndexSet(index: section as! Int))
                    default:
                        break
                    }
                }
            }
            for itemChange in self.itemChanges {
                for (type, indexPaths) in itemChange {
                    let castedIndexPaths = indexPaths as! [NSIndexPath]
                    switch type as! NSFetchedResultsChangeType {
                    case .Insert:
                        self.collectionView?.insertItemsAtIndexPaths(castedIndexPaths)
                    case .Delete:
                        self.collectionView?.deleteItemsAtIndexPaths(castedIndexPaths)
                    case .Update:
                        self.collectionView?.reloadItemsAtIndexPaths(castedIndexPaths)
                    case .Move:
                        self.collectionView?.moveItemAtIndexPath(castedIndexPaths.first!, toIndexPath: castedIndexPaths.last!)
                    }
                }
            }
            }, completion: { finished in
                self.sectionChanges.removeAll(keepCapacity: false)
                self.itemChanges.removeAll(keepCapacity: false)
        })
    }
}

// MARK: Private methods to deal with Objective-C's dinosaur's behaviours.

private extension NSNumber {
    convenience init(changeType: NSFetchedResultsChangeType) {
        self.init(unsignedLong: changeType.rawValue)
    }
}
