//
//  FetchedResultsCollectionViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 20/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, List {

    // MARK: Properties

    public var fetchResultsController: NSFetchedResultsController! {
        didSet {
            sectionChanges.removeAll(keepCapacity: false)
            itemChanges.removeAll(keepCapacity: false)
            fetchResultsController.delegate = self
        }
    }

    private let cellIdentifier = "Fetched Cell"

    private var sectionChanges = [[NSFetchedResultsChangeType: Int]]()
    private var itemChanges = [[NSFetchedResultsChangeType: [NSIndexPath]]]()
    
    // MARK: Abstract Methods
    
    public func listView(listView: UIView, configureCell cell: UIView, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func listView(listView: UIView, didSelectObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return cellIdentifier
    }
    
    // MARK: Collection view
    
    override public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            let section = sections[section] as NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
        return 0
    }

    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath)
        listView(collectionView, configureCell: cell, withObject: object, atIndexPath: indexPath)

        return cell
    }
    
    override public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath)
        listView(collectionView, didSelectObject: object, atIndexPath: indexPath)
    }

    // MARK: Fetched Results Controller

    public func performFetch() throws {
        try fetchResultsController.performFetch()
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        var change = [NSFetchedResultsChangeType: Int]()
        change[type] = sectionIndex
        sectionChanges += [change]
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var change = [NSFetchedResultsChangeType: [NSIndexPath]]()
        switch type {
        case .Insert:
            change[type] = [newIndexPath!]
        case .Delete:
            change[type] = [indexPath!]
        case .Update:
            change[type] = [indexPath!]
        case .Move:
            change[type] = [indexPath!, newIndexPath!]
        }
        itemChanges += [change]
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({
            for sectionChange in self.sectionChanges {
                for (type, section) in sectionChange {
                    switch type {
                    case .Insert:
                        self.collectionView?.insertSections(NSIndexSet(index: section))
                    case .Delete:
                        self.collectionView?.deleteSections(NSIndexSet(index: section))
                    default:
                        break
                    }
                }
            }
            for itemChange in self.itemChanges {
                for (type, indexPaths) in itemChange {
                    switch type {
                    case .Insert:
                        self.collectionView?.insertItemsAtIndexPaths(indexPaths)
                    case .Delete:
                        self.collectionView?.deleteItemsAtIndexPaths(indexPaths)
                    case .Update:
                        self.collectionView?.reloadItemsAtIndexPaths(indexPaths)
                    case .Move:
                        self.collectionView?.moveItemAtIndexPath(indexPaths.first!, toIndexPath: indexPaths.last!)
                    }
                }
            }
        }, completion: { finished in
            self.sectionChanges.removeAll(keepCapacity: false)
            self.itemChanges.removeAll(keepCapacity: false)
        })
    }
}
