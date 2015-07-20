//
//  FetchedResultsTableViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 20/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsTableViewController: UITableViewController, TableFetchedList {
    
    // MARK: Properties
    
    public var fetchedResultsController: NSFetchedResultsController! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    
    private let cellIdentifier = "Fetched Cell"
    
    // MARK: TableFetchedList

    public func listView(listView: UIView, configureCell cell: UIView, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func listView(listView: UIView, didSelectObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return cellIdentifier
    }
    
    public func updateTableCell(cell: UITableViewCell, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        
    }
}
