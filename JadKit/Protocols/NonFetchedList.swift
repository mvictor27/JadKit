//
//  NonFetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/25/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import Foundation

/**
 The basic beahviour that a non fetched list needs to implement. This is
 rather basic, as all a non-fetched list really needs is a data source.
 */
@objc public protocol NonFetchedList: List {
  // FIXME: There must be a good way to allow for felxible rows + col.
  /// The list data used to populate the list. This an array  to
  /// populate the rows. Currently this is limited to a single section.
  var listData: [AnyObject]! { get set }
}

/**
 Protocol extension to implement the basic non fetched list methods.
 */
public extension NonFetchedList {
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
    return listData[indexPath.row]
  }

  /**
   Conveneient helper method to ensure that a given index path is valid.
   - note: This method is implemented by a protocol extension if the object
   conforms to either `FetchedList` or `NonFetchedList`
   - parameter indexPath: The index path to check for existance.
   - returns: `true` iff the index path is valid for your data source.
   */
  func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
    guard indexPath.section >= 0 else {
      return false
    }
    return indexPath.row >= 0 && indexPath.row < listData.count
  }
}

// MARK: Table

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid table view protocol extension implementation.
 */
@objc public protocol TableList: NonFetchedList,
  UITableViewDataSource, UITableViewDelegate { }

/**
 Protocol extension to implement the table view delegate & data source methods.
 */
public extension TableList {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return listData.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath
    indexPath: NSIndexPath) -> UITableViewCell {
    let identifier = cellIdentifierForIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(identifier,
                                                           forIndexPath: indexPath)

    if let object = objectAtIndexPath(indexPath) {
      listView(tableView, configureCell: cell, withObject: object,
                                               atIndexPath: indexPath)
    }

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath
    indexPath: NSIndexPath) {
    if let object = objectAtIndexPath(indexPath) {
      listView(tableView, didSelectObject: object,
                          atIndexPath: indexPath)
    }
  }
}

// MARK: Collection

/**
 Empty protocol to set up the conformance to the various protocols to allow
 for a valid collection view protocol extension implementation.
 */
@objc public protocol CollectionList: NonFetchedList,
  UICollectionViewDataSource, UICollectionViewDelegate { }

/**
 Protocol extension to implement the collection view delegate & data
 source methods.
 */
public extension CollectionList {
  func collectionView(collectionView: UICollectionView,
       numberOfItemsInSection section: Int) -> Int {
    return listData.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath
    indexPath: NSIndexPath) -> UICollectionViewCell {
    let identifier = cellIdentifierForIndexPath(indexPath)

    let cell =
      collectionView.dequeueReusableCellWithReuseIdentifier(identifier,
                                                            forIndexPath: indexPath) as UICollectionViewCell

    if let object = objectAtIndexPath(indexPath) {
      listView(collectionView, configureCell: cell,
                               withObject: object, atIndexPath: indexPath)
    }

    return cell
  }

  func collectionView(collectionView: UICollectionView,
       didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let object = objectAtIndexPath(indexPath) {
      listView(collectionView, didSelectObject: object,
                               atIndexPath: indexPath)
    }
  }
}