//
//  FetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/13/15.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//
//  --------------------------------------------
//
//  Implements the protocol and their extensions to get a Core Data backed fetched list going.
//
//  --------------------------------------------
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice,
//  this list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
//  THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation
import CoreData

/**
 The basic beahviour that a fetched list needs to implement. The core
 of a fetched list is a `NSFetchedResultsController` object that the
 conforming object will need to create in order to properly calculate the
 list data.
 */
public protocol FetchedList: List, NSFetchedResultsControllerDelegate {
  /// The fetched results controller that will be used to populate the list
  /// dynamically as the backing store is updated.
  var fetchedResultsController: NSFetchedResultsController! { get set }
}

/**
 Protocol extension to implement the basic fetched list methods.
 */
public extension FetchedList {
  /// The number of sections fetched by the `fetchedResultsController`.
  var numberOfSections: Int {
    return fetchedResultsController?.sections?.count ?? 0
  }

  /// The index titles for the fetched list.
  var sectionIndexTitles: [AnyObject]? {
    return fetchedResultsController?.sectionIndexTitles
  }

  /**
   The number of rows in a section fetched by the `fetchedResultsController`.
   - parameter section: The section in which the row count will be returned.
   - returns: The number of rows in a given section. `0` if the section is
   not found.
   */
  func numberOfRowsInSection(section: Int) -> Int {
    if let sections = fetchedResultsController?.sections {
      return sections[section].numberOfObjects
    }
    return 0
  }

  /**
   Conveneient helper method to ensure that a given index path is valid.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `FetchedList` or `NonFetchedList`
   - parameter indexPath: The index path to check for existance.
   - returns: `true` iff the index path is valid for your data source.
   */
  func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
    guard indexPath.section < numberOfSections && indexPath.section >= 0 else {
      return false
    }
    return indexPath.row < numberOfRowsInSection(indexPath.section) && indexPath.row >= 0
  }

  /**
   Convenient helper method to find the object at a given index path.
   This method works well with `isValidIndexPath:`.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `FetchedList` or `NonFetchedList`
   - parameter indexPath: The index path to retreive the object for.
   - returns: An optional with the corresponding object at an index
   path or nil if the index path is invalid.
   */
  func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
    guard isValidIndexPath(indexPath) else {
      return nil
    }
    return fetchedResultsController?.objectAtIndexPath(indexPath)
  }

  /**
   Helper method to grab the title for a header for a given section.
   - parameter section: The section for the header's title to grab.
   - returns: The header title for the section or `nil` if none is found.
   */
  func titleForHeaderInSection(section: Int) -> String? {
    guard isValidIndexPath(NSIndexPath(forRow: 0, inSection: section)) else {
      return nil
    }
    return fetchedResultsController?.sections?[section].name
  }
}

// MARK: Table

/**
 Protocol to set up the conformance to the various protocols to allow
 for a valid table view protocol extension implementation.
 */
public protocol FetchedTableList: FetchedList, UITableViewDataSource, UITableViewDelegate {
    /// The table view that will be updated as the `fetchedResultsController`
    /// is updated.
    var tableView: UITableView! { get set }
}

/**
 Protocol extension to implement the table view delegate & data source methods.
 */
public extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell,
  Object == AnyObject {
    /**
     Method to call in `tableView:cellForRowAtIndexPath:`.
     - parameter indexPath: An index path locating a row in `tableView`
     */
    func tableCellAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
      let identifier = cellIdentifierForIndexPath(indexPath)
      let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)

      if let object = objectAtIndexPath(indexPath) {
        listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
      }

      return cell
    }

    /**
     Method to call in `tableView:didSelectRowAtIndexPath:`.
     - parameter indexPath: An index path locating the new selected row in `tableView`.
     */
    func tableDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
      if let object = objectAtIndexPath(indexPath) {
        listView(tableView, didSelectObject: object, atIndexPath: indexPath)
      }
    }
}

/**
 Protocol extension to implement the fetched results controller
 sdelegate methods.
 */
public extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell,
  Object == AnyObject {
    /**
     Method to call in `controllerWillChangeContent:`.
     */
    func tableWillChangeContent() {
      tableView.beginUpdates()
    }

    /**
     Method to call in `controller:didChangeSection:atIndex:forChangeType:`.
     - parameter sectionIndex: The index of the changed section.
     - parameter type: The type of change (insert or delete). Valid values are
     `NSFetchedResultsChangeInsert` and `NSFetchedResultsChangeDelete`.
     */
    func tableDidChangeSection(sectionIndex: Int, withChangeType type: NSFetchedResultsChangeType) {
      switch type {
      case .Insert:
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
      case .Delete:
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
      case .Update:
        tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
      default:
        // FIXME: Figure out what to do with .Move
        break
      }
    }

    /**
     Method to call in `controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:`.
     - parameter indexPath: The index path of the changed object (this value is `nil`
     for insertions).
     - parameter type: The type of change. For valid values see `NSFetchedResultsChangeType`
     - parameter newIndexPath: The destination path for the object for insertions or moves
     (this value is `nil` for a deletion).
     */
    func tableDidChangeObjectAtIndexPath(indexPath: NSIndexPath?,
                                         withChangeType type: NSFetchedResultsChangeType,
                                         newIndexPath: NSIndexPath?) {
      switch type {
      case .Insert:
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
      case .Delete:
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
      case .Update:
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
      case .Move:
        tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
      }
    }

    /**
     Method to call in `controllerDidChangeContent:`
     */
    func tableDidChangeContent() {
      tableView.endUpdates()
    }
}

// MARK: Collection

/**
 Protocol to set up the conformance to the various protocols to allow
 for a valid collection view protocol extension implementation.
 */
public protocol FetchedCollectionList: FetchedList, UICollectionViewDataSource,
  UICollectionViewDelegate {
    // FIXME: collectionView is still an optional on UICollectionViewController
    // Update this when Apple updates the Swift interface.
    /// The collection view to update with the fetched changes.
    var collectionView: UICollectionView? { get set }

    /// Classes that conform to this protocol need only to initialise this
    /// property. It is an array of block operations used to hold the section
    /// and row changes so that the collection view can be animated in the same
    /// way a table view controller handles section changes.
    var changeOperations: [NSBlockOperation] { get set }
}

/**
 Protocol extension to implement the custom source methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
  Cell == UICollectionViewCell, Object == AnyObject {
    /**
     Cancel the queued up collection view row & section changes.
    */
    func cancelCollectionViewChangeOperations() {
      for operation: NSBlockOperation in changeOperations {
        operation.cancel()
      }
      changeOperations.removeAll(keepCapacity: false)
    }
}

/**
 Protocol extension to implement the collection view delegate &
 data source methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
  Cell == UICollectionViewCell, Object == AnyObject {
    /**
     Method to call in `collectionView:cellForItemAtIndexPath:`.
     - parameter indexPath: The index path that specifies the location of the item.
     */
    func collectionCellAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewCell {
      let identifier = cellIdentifierForIndexPath(indexPath)

      let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(identifier,
                                                                       forIndexPath: indexPath)

      if let object = objectAtIndexPath(indexPath) {
        listView(collectionView!, configureCell: cell, withObject: object, atIndexPath: indexPath)
      }

      return cell
    }

    /**
     Method to call in `collectionView:didSelectItemAtIndexPath:`.
     - parameter indexPath: The index path of the cell that was selected.
     */
    func collectionDidSelectItemAtIndexPath(indexPath: NSIndexPath) {
      if let object = objectAtIndexPath(indexPath) {
        listView(collectionView!, didSelectObject: object, atIndexPath: indexPath)
      }
    }
}

/**
 Protocol extension to implement the fetched results controller
 sdelegate methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
  Cell == UICollectionViewCell, Object == AnyObject {
    /**
     Method to call in `controllerWillChangeContent:`.
     */
    func collectionWillChangeContent() {
      self.changeOperations.removeAll(keepCapacity: false)
    }

    /**
     Method to call in `controller:didChangeSection:atIndex:forChangeType:`.
     - parameter sectionIndex: The index of the changed section.
     - parameter type: The type of change (insert or delete). Valid values are
     `NSFetchedResultsChangeInsert` and `NSFetchedResultsChangeDelete`.
     */
    func collectionDidChangeSection(sectionIndex: Int,
                                    withChangeType type: NSFetchedResultsChangeType) {
      let indexSet = NSIndexSet(index: sectionIndex)

      switch type {
      case .Insert:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.insertSections(indexSet)
          })
      case .Update:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.reloadSections(indexSet)
          })
      case .Delete:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.deleteSections(indexSet)
          })
      default:
        break
      }
    }

    /**
     Method to call in `controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:`.
     - parameter indexPath: The index path of the changed object (this value is `nil`
     for insertions).
     - parameter type: The type of change. For valid values see `NSFetchedResultsChangeType`
     - parameter newIndexPath: The destination path for the object for insertions or moves
     (this value is `nil` for a deletion).
     */
    func collectionDidChangeObjectAtIndexPath(indexPath: NSIndexPath?,
                                              withChangeType type: NSFetchedResultsChangeType,
                                              newIndexPath: NSIndexPath?) {
      switch type {
      case .Insert:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
          })
      case .Update:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.reloadItemsAtIndexPaths([indexPath!])
          })
      case .Move:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
          })
      case .Delete:
        changeOperations.append(
          NSBlockOperation { [weak self] in
            self?.collectionView!.deleteItemsAtIndexPaths([indexPath!])
          })
      }
    }

    /**
     Method to call in `controllerDidChangeContent:`
     */
    func collectionDidChangeContent() {
      for section in fetchedResultsController.sections! {
        print(section.numberOfObjects)
      }

      collectionView!.performBatchUpdates({
        for operation in self.changeOperations {
          operation.start()
        }
      }, completion: { [weak self] finished in
          self?.changeOperations.removeAll(keepCapacity: false)
      })
    }
}
