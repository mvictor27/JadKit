//
//  NonFetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/25/15.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//
//  --------------------------------------------
//
//  Implements the protocol and their extensions to get a simple non-fetched list going.
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

/**
 The basic beahviour that a non fetched list needs to implement. This is
 rather basic, as all a non-fetched list really needs is a data source.
 */
public protocol NonFetchedList: List {
    /// The list data used to populate the list. This an array  to
    /// populate the rows. Currently this is limited to a single section.
    var listData: [[Object]]! { get set }
}

/**
 Protocol extension to implement the basic non fetched list methods.
 */
public extension NonFetchedList {
    /// The number of sections in the `listData`.
    var numberOfSections: Int {
        return listData?.count ?? 0
    }
    
    /**
     The number of rows in a section of the `listData`.
     - parameter section: The section in which the row count will be returned.
     - returns: The number of rows in a given section. `0` if the section is
     not found.
     */
    func numberOfRows(inSection section: Int) -> Int {
        guard listData != nil && section >= 0 && section < listData!.count else {
            return 0
        }
        return listData![section].count
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
        return listData?[indexPath.section][indexPath.row]
    }
    
    /**
     Conveneient helper method to ensure that a given index path is valid.
     - note: This method is implemented by a protocol extension if the object
     conforms to either `FetchedList` or `NonFetchedList`
     - parameter indexPath: The index path to check for existance.
     - returns: `true` iff the index path is valid for your data source.
     */
    func isValid(_ indexPath: IndexPath) -> Bool {
        guard listData != nil && indexPath.section >= 0 && indexPath.section < listData!.count else {
            return false
        }
        return indexPath.row >= 0 && indexPath.row < listData![indexPath.section].count
    }
}

// MARK: Table

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid table view protocol extension implementation.
 */
public protocol TableList: NonFetchedList, UITableViewDataSource, UITableViewDelegate {
    /// The table view that will present the data.
    var tableView: UITableView! { get set }
}

/**
 Protocol extension to implement the table view delegate & data source methods.
 */
public extension TableList where ListView == UITableView, Cell == UITableViewCell {
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

// MARK: Collection

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid collection view protocol extension implementation.
 */
public protocol CollectionList: NonFetchedList, UICollectionViewDataSource, UICollectionViewDelegate {
    /// The collection view that will present the data.
    var collectionView: UICollectionView! { get set }
}

/**
 Protocol extension to implement the collection view delegate & data
 source methods.
 */
public extension CollectionList where ListView == UICollectionView, Cell == UICollectionViewCell {
    /**
     Method to call in `collectionView:cellForItemAt:`.
     - parameter indexPath: The index path that specifies the location of the item.
     */
    func collectionCell(at indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = cellIdentifier(for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
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
