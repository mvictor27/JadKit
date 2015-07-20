//
//  CollectionFetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/13/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

@objc public protocol CollectionFetchedList: FetchedList {
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

// NARK: Private methods to deal with Objective-C's dinosaur's behaviours.

private extension NSNumber {
    convenience init(changeType: NSFetchedResultsChangeType) {
        self.init(unsignedLong: changeType.rawValue)
    }
}
