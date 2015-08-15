//
//  NonFetchedList.swift
//  JadKit
//
//  Created by Jad Osseiran on 7/25/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import Foundation

// MARK: - NonFetchedList

@objc public protocol NonFetchedList: List {
    /// The list data used to populate the list. This an array  to
    /// populate the rows. Currently this is limited to a single section.
    var listData: [AnyObject]! { get set }
}
 
public extension NonFetchedList {
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return listData[indexPath.row]
    }
    
    func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        if indexPath.section != 0 {
            return false
        }
        return indexPath.row >= 0 && indexPath.row < listData.count
    }
}

// MARK: - Table

@objc public protocol TableList: NonFetchedList, UITableViewDataSource, UITableViewDelegate { }

public extension TableList {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let object = listData[indexPath.row]
        listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = listData[indexPath.row]
        listView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
}

// MARK: Collection

@objc public protocol CollectionList: NonFetchedList, UICollectionViewDataSource, UICollectionViewDelegate { }

public extension CollectionList {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        let object = listData[indexPath.row]
        listView(collectionView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object = listData[indexPath.row]
        listView(collectionView, didSelectObject: object, atIndexPath: indexPath)
    }
}
