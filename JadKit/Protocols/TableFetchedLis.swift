//
//  TableFetchedLis.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/13/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import UIKit
import CoreData

@objc public protocol TableFetchedList: FetchedList {
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
