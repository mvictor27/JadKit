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
    /// The list data used to populate the list. This an array of arrays to
    /// populate the sections and rows. The outer array will be used for the
    /// sections and the inner one for the rows.
    var listData: [[AnyObject]]! { get set }
}
 
public extension NonFetchedList {
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return listData[indexPath.section][indexPath.row]
    }
    
    func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        if indexPath.section >= 0 && indexPath.section < listData.count {
            return indexPath.row >= 0 && indexPath.row < listData[indexPath.section].count
        }
        return false
    }
}

// MARK: - Table

@objc public protocol TableList: NonFetchedList, UITableViewDataSource, UITableViewDelegate { }

public extension TableList {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return listData.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let object = listData[indexPath.section][indexPath.row]
        listView(tableView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = listData[indexPath.section][indexPath.row]
        listView(tableView, didSelectObject: object, atIndexPath: indexPath)
    }
}

// MARK: Collection

@objc public protocol CollectionList: NonFetchedList, UICollectionViewDataSource, UICollectionViewDelegate { }

public extension CollectionList {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return listData.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listData[section].count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellIdentifier = cellIdentifierForIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
        
        let object = listData[indexPath.section][indexPath.row]
        listView(collectionView, configureCell: cell, withObject: object, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let object = listData[indexPath.section][indexPath.row]
        listView(collectionView, didSelectObject: object, atIndexPath: indexPath)
    }
}
