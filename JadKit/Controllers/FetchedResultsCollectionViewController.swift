//
//  FetchedResultsCollectionViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 20/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsCollectionViewController: UICollectionViewController, CollectionFetchedList {

    // MARK: Properties

    public var fetchedResultsController: NSFetchedResultsController! {
        didSet {
            sectionChanges.removeAll(keepCapacity: false)
            itemChanges.removeAll(keepCapacity: false)
            fetchedResultsController.delegate = self
        }
    }

    private let cellIdentifier = "Fetched Cell"

    public var sectionChanges = [NSMutableDictionary]()
    public var itemChanges = [NSMutableDictionary]()
    
    // MARK: CollectionFetchedList
    
    public func listView(listView: UIView, configureCell cell: UIView, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func listView(listView: UIView, didSelectObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return cellIdentifier
    }
    
    public func updateCollectionCell(cell: UICollectionViewCell, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {

    }
}
