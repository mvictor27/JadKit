//
//  CoreDataFetcher.swift
//  JadKit
//
//  Created by Jad Osseiran on 6/06/2015.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import Foundation
import CoreData

public class FetchedSectionChange: NSObject {
    let sectionInfo: NSFetchedResultsSectionInfo
    let sectionIndex: Int
    let changeType: NSFetchedResultsChangeType

    private init(sectionInfo: NSFetchedResultsSectionInfo, sectionIndex: Int, changeType: NSFetchedResultsChangeType) {
        self.sectionInfo = sectionInfo
        self.sectionIndex = sectionIndex
        self.changeType = changeType
    }
}

public class FetchedObjectChange: NSObject {
    let object: AnyObject
    let changeType: NSFetchedResultsChangeType

    private(set) var oldIndexPath: NSIndexPath?
    private(set) var newIndexPath: NSIndexPath?

    private init(object: AnyObject, changeType: NSFetchedResultsChangeType, oldIndexPath: NSIndexPath?, newIndexPath: NSIndexPath?) {
        self.object = object
        self.changeType = changeType
        self.oldIndexPath = oldIndexPath
        self.newIndexPath = newIndexPath
    }
}

@objc public protocol CoreDataFetcherDelegate: NSObjectProtocol {
    optional func dataFetcherWillChangeContent(fetcher: CoreDataFetcher)

    optional func dataFetcher(fetcher: CoreDataFetcher, didChangeSection sectionChange: FetchedSectionChange)

    optional func dataFetcher(fetcher: CoreDataFetcher, didChangeObject objectChange: FetchedObjectChange)

    optional func dataFetcherDidChangeContent(fetcher: CoreDataFetcher)
}

public class CoreDataFetcher: NSObject, NSFetchedResultsControllerDelegate {
    public typealias DataFetchClosure = (changedObjects: [FetchedObjectChange], changedSections: [FetchedSectionChange]) -> Void
    public typealias CellUpdateClosure = (cell: UIView, object: AnyObject, indexPath: NSIndexPath) -> Void

    public weak var delegate: CoreDataFetcherDelegate?

    public var dataFetchHandler: DataFetchClosure?

    public var cellUpateHandler: CellUpdateClosure?

    public var fetchResultsController: NSFetchedResultsController {
        didSet {
            fetchResultsController.delegate = self
        }
    }

    public private(set) var fetchingView: UIView!

    // MARK: Init

    public init(fetchResultsController: NSFetchedResultsController) {
        self.fetchResultsController = fetchResultsController
        super.init()
    }

    public convenience init(fetchResultsController: NSFetchedResultsController, dataFetchHandler: DataFetchClosure!) {
        self.init(fetchResultsController: fetchResultsController)

        self.dataFetchHandler = dataFetchHandler
    }

    // MARK: Methods

    public func performFetch() throws {
        try fetchResultsController.performFetch()
    }

    public func numberOfSection() -> Int {
        return fetchResultsController.sections?.count ?? 0
    }

    public func numberOfRowsInSection(section: Int) -> Int {
        if let sections = fetchResultsController.sections {
            let section = sections[section] as NSFetchedResultsSectionInfo
            return section.numberOfObjects
        }
        return 0
    }

    public func titleForHeaderInSection(section: Int) -> String? {
        let section = fetchResultsController.sections?[section]
        return section?.name
    }

    public func sectionForSectionIndexTitle(title: String, atIndex index: Int) -> Int {
        return fetchResultsController.sectionForSectionIndexTitle(title, atIndex: index)
    }

    public func sectionIndexTitles() -> [AnyObject]! {
        return fetchResultsController.sectionIndexTitles
    }

    public func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if isValidIndexPath(indexPath) == false {
            return nil
        }
        return fetchResultsController.objectAtIndexPath(indexPath)
    }

    public func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        let numSections = numberOfSection()
        let validSection = indexPath.section < numSections && indexPath.section >= 0

        let numRows = numberOfRowsInSection(indexPath.section)
        let validRow = indexPath.row < numRows && indexPath.row >= 0

        return validSection && validRow
    }

    // MARK: Fetched Results Controller Delegate

    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let view = fetchingView {
            if view is UITableView {
                tableViewHandleControllerWillChangeContent(controller)
            } else if view is UICollectionView {
                collectionViewHandleControllerWillChangeContentFor(controller)
            } else {
                print("The view provided is not supported by the fetcher. It will ignore this view: \(view)")
            }
        }

        delegate?.dataFetcherWillChangeContent?(self)
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if let view = fetchingView {
            if view is UITableView {
                tableViewHandleController(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
            } else if view is UICollectionView {
                collectionViewHandleController(controller, didChangeSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
            } else {
                print("The view provided is not supported by the fetcher. It will ignore this view: \(view)")
            }
        }

        let sectionChange = FetchedSectionChange(sectionInfo: sectionInfo, sectionIndex: sectionIndex, changeType: type)
        delegate?.dataFetcher?(self, didChangeSection: sectionChange)
    }

  public func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let view = fetchingView {
            if view is UITableView {
                tableViewHandleController(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
            } else if view is UICollectionView {
                collectionViewHandleController(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
            } else {
                print("The view provided is not supported by the fetcher. It will ignore this view: \(view)")
            }
        }

        let objectChange = FetchedObjectChange(object: anObject, changeType: type, oldIndexPath: indexPath, newIndexPath: newIndexPath)
        delegate?.dataFetcher?(self, didChangeObject: objectChange)
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let view = fetchingView {
            if view is UITableView {
                tableViewHandleControllerDidChangeContent(controller)
            } else if view is UICollectionView {
                collectionViewHandleControllerDidChangeContent(controller)
            } else {
                print("The view provided is not supported by the fetcher. It will ignore this view: \(view)")
            }
        }

      // FIXME:
//        dataFetchHandler?(balh blah blah)
        delegate?.dataFetcherDidChangeContent?(self)
    }
}

// MARK: TableView

public extension CoreDataFetcher {

    var tableView: UITableView! {
        return fetchingView as? UITableView
    }

    public convenience init(fetchResultsController: NSFetchedResultsController, tableView: UITableView!,cellUpateHandler: CellUpdateClosure!) {
        self.init(fetchResultsController: fetchResultsController)

        self.cellUpateHandler = cellUpateHandler
    }

    private func tableViewHandleControllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }

    private func tableViewHandleController(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }

    private func tableViewHandleController(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            if let cell = tableView?.cellForRowAtIndexPath(indexPath!) {
                let object: AnyObject = fetchResultsController.objectAtIndexPath(indexPath!)
                cellUpateHandler?(cell: cell, object: object, indexPath: indexPath!)
            }
        case .Move:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        }
    }

    private func tableViewHandleControllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }
}

// MARK: CollectionView

public extension CoreDataFetcher {

    private func collectionViewHandleControllerWillChangeContentFor(controller: NSFetchedResultsController) {

    }

    private func collectionViewHandleController(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

    }

    private func collectionViewHandleController(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    }

    private func collectionViewHandleControllerDidChangeContent(controller: NSFetchedResultsController) {

    }
}
