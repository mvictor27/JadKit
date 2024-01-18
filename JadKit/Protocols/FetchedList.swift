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
public protocol FetchedList: List, NSFetchedResultsControllerDelegate where Object: NSFetchRequestResult {
    
    
    /// The fetched results controller that will be used to populate the list
    /// dynamically as the backing store is updated.
    var fetchedResultsController: NSFetchedResultsController<Object>! { get set }
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
  var sectionIndexTitles: [String]? {
      return fetchedResultsController?.sectionIndexTitles
  }

  /**
   The number of rows in a section fetched by the `fetchedResultsController`.
   - parameter section: The section in which the row count will be returned.
   - returns: The number of rows in a given section. `0` if the section is
   not found.
   */
  func numberOfRows(inSection section: Int) -> Int {
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
  func isValid(_ indexPath: IndexPath) -> Bool {
    guard indexPath.section < numberOfSections && indexPath.section >= 0 else {
      return false
    }
      return indexPath.row < numberOfRows(inSection: indexPath.section) && indexPath.row >= 0
  }

  /**
   Convenient helper method to find the object at a given index path.
   This method works well with `isValid:`.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `FetchedList` or `NonFetchedList`
   - parameter indexPath: The index path to retreive the object for.
   - returns: An optional with the corresponding object at an index
   path or nil if the index path is invalid.
   */
    func object(at indexPath: IndexPath) -> Object? {
    guard isValid(indexPath) else {
      return nil
    }
    return fetchedResultsController?.object(at: indexPath)
  }

  /**
   Helper method to grab the title for a header for a given section.
   - parameter section: The section for the header's title to grab.
   - returns: The header title for the section or `nil` if none is found.
   */
  func titleForHeader(inSection section: Int) -> String? {
    guard isValid(IndexPath(row: 0, section: section)) else {
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
public extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell {
    /**
     Method to call in `tableView:cellForRowAt:`.
     - parameter indexPath: An index path locating a row in `tableView`
     */
    func tableCell(at indexPath: IndexPath) -> UITableViewCell {
        let identifier = cellIdentifier(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let object = object(at: indexPath) {
            listView(tableView, configure: cell, with: object, at: indexPath)
        }
        
        return cell
    }
    
    /**
     Method to call in `tableView:didSelectRowAt:`.
     - parameter indexPath: An index path locating the new selected row in `tableView`.
     */
    func tableDidSelectItem(at indexPath: IndexPath) {
        if let object = object(at: indexPath) {
            listView(tableView, didSelect: object, at: indexPath)
        }
    }
}

/**
 Protocol extension to implement the fetched results controller
 sdelegate methods.
 */
public extension FetchedTableList where ListView == UITableView, Cell == UITableViewCell {
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
    func tableDidChangeSection(_ section: Int, withChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: section), with: .automatic)
            case .delete:
                tableView.deleteSections(IndexSet(integer: section), with: .automatic)
            case .update:
                tableView.reloadSections(IndexSet(integer: section), with: .automatic)
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
    func tableDidChangeObject(at indexPath: IndexPath?,
                              withChangeType type: NSFetchedResultsChangeType,
                              newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            default:
                break
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
    /// The collection view to update with the fetched changes.
    var collectionView: UICollectionView! { get set }

    /// Classes that conform to this protocol need only to initialise this
    /// property. It is an array of block operations used to hold the section
    /// and row changes so that the collection view can be animated in the same
    /// way a table view controller handles section changes.
    var changeOperations: [BlockOperation] { get set }
}

/**
 Protocol extension to implement the custom source methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
  Cell == UICollectionViewCell {
    /**
     Cancel the queued up collection view row & section changes.
    */
    func cancelCollectionViewChangeOperations() {
      for operation: BlockOperation in changeOperations {
        operation.cancel()
      }
      changeOperations.removeAll(keepingCapacity: false)
    }
}

/**
 Protocol extension to implement the collection view delegate &
 data source methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
  Cell == UICollectionViewCell {
    /**
     Method to call in `collectionView:cellForItemAt:`.
     - parameter indexPath: The index path that specifies the location of the item.
     */
    func collectionCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = cellIdentifier(for: indexPath)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                       for: indexPath)

      if let object = object(at: indexPath) {
          listView(collectionView, configure: cell, with: object, at: indexPath)
      }

      return cell
    }

    /**
     Method to call in `collectionView:didSelectItemAt:`.
     - parameter indexPath: The index path of the cell that was selected.
     */
    func collectionDidSelectItem(at indexPath: IndexPath) {
      if let object = object(at: indexPath) {
          listView(collectionView, didSelect: object, at: indexPath)
      }
    }
}

/**
 Protocol extension to implement the fetched results controller
 sdelegate methods.
 */
public extension FetchedCollectionList where ListView == UICollectionView,
                                             Cell == UICollectionViewCell {
    /**
     Method to call in `controllerWillChangeContent:`.
     */
    func collectionWillChangeContent() {
        self.changeOperations.removeAll(keepingCapacity: false)
    }
    
    /**
     Method to call in `controller:didChangeSection:atIndex:forChangeType:`.
     - parameter sectionIndex: The index of the changed section.
     - parameter type: The type of change (insert or delete). Valid values are
     `NSFetchedResultsChangeInsert` and `NSFetchedResultsChangeDelete`.
     */
    func collectionDidChangeSection(sectionIndex: Int,
                                    withChangeType type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
            case .insert:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.insertSections(indexSet)
                    })
            case .update:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.reloadSections(indexSet)
                    })
            case .delete:
                changeOperations.append(
                    BlockOperation { [weak self] in
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
    func collectionDidChangeObject(at indexPath: IndexPath?,
                                   withChangeType type: NSFetchedResultsChangeType,
                                   newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.insertItems(at: [newIndexPath!])
                    })
            case .update:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.reloadItems(at: [indexPath!])
                    })
            case .move:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
                    })
            case .delete:
                changeOperations.append(
                    BlockOperation { [weak self] in
                        self?.collectionView!.deleteItems(at: [indexPath!])
                    })
            default:
                return
        }
    }
    
    /**
     Method to call in `controllerDidChangeContent:`
     */
    func collectionDidChangeContent() {
        for section in fetchedResultsController.sections! {
            print(section.numberOfObjects)
        }
        
        collectionView.performBatchUpdates({
            for operation in self.changeOperations {
                operation.start()
            }
        }, completion: { [weak self] finished in
            self?.changeOperations.removeAll(keepingCapacity: false)
        })
    }
}
