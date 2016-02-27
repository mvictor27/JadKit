//
//  List.swift
//  JadKit
//
//  Created by Jad Osseiran on 21/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit

/**
 This protocol outlines the most basic bhaviour that a list should implement.
 */
@objc public protocol List {
  /**
   The cell identifier for the given index path.
   - parameter indexPath: The index path of the cell.
   - returns: The cell identifier.
   */
  func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String

  /**
   Helper method to configure a cell at the given index path with a given
   object.
   - parameter listView: The list view that is cnofiguring the cell.
   - parameter cell: The cell to configure.
   - parameter object: The object which matches the cell's index path.
   - parameter indexPath: The index path of the cell to configure.
   */
  func listView(listView: UIView, configureCell cell: UIView,
       withObject object: AnyObject, atIndexPath indexPath: NSIndexPath)

  /**
   Called when the user selects a cell at the given index path.
   - parameter listView: The list view that is interacted with.
   - parameter object: The object at the selected index path.
   - parameter indexPath: The index path of the cell which was selected.
   */
  func listView(listView: UIView, didSelectObject object: AnyObject,
       atIndexPath indexPath: NSIndexPath)
}
