//
//  FetchedResultsTableViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 20/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

public class FetchedResultsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, List {
    
    // MARK: Properties
    
    public var fetchResultsController: NSFetchedResultsController! {
        didSet {
            fetchResultsController.delegate = self
        }
    }
    
    private let cellIdentifier = "Fetched Cell"
    
    // MARK:- Abstract Methods

    public func listView(listView: UIView, configureCell cell: UIView, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func listView(listView: UIView, didSelectObject object: AnyObject, atIndexPath indexPath: NSIndexPath) {
        // Override me!
    }
    
    public func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return cellIdentifier
    }
    
    // MARK: Table View
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            let section = sections[section] as NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
        return 0
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchResultsController.sections?[section]
        return section?.name
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchResultsController.sectionIndexTitles
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath)
        listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath)
        listView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
    
    // MARK: Fetched Results Controller
    
    public func performFetch() throws {
        try fetchResultsController.performFetch()
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            if let cell = tableView?.cellForRowAtIndexPath(indexPath!) {
                let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath!)
                listView(self.tableView, configureCell: cell, withObject: object, atIndexPath: indexPath!)
            }
        case .Move:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }
}
