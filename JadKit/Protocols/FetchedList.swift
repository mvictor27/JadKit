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
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
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
