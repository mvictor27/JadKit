//
//  List.swift
//  JadKit
//
//  Created by Jad Osseiran on 21/12/2014.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit

public protocol List {
    
    /**
     *  Helper method to configure a cell at the given index path with a given
     *  object.
     *
     *  :param: listView  The list view who's cell is configured.
     *  :param: cell      The cell to configure.
     *  :param: object    The object which matches the cell's index path.
     *  :param: indexPath The index path of the cell to configure.
     */
    func listView(listView: UIView, configureCell cell: UIView, withObject object: AnyObject, atIndexPath indexPath: NSIndexPath)
    
    /**
     *  Called when the user selects a cell a the given index path.
     *
     *  :param: listView The list view who is interacted with.
     *  :param: object    The object at the selected index path.
     *  :param: indexPath The index path of the cell which was selected.
     */
    func listView(listView: UIView, didSelectObject object: AnyObject, atIndexPath indexPath: NSIndexPath)
    
    /**
     *  The cell identifier for the given index path.
     *
     *  :param: indexPath The index path of the cell.
     *
     *  :returns: The cell identifier.
     */
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String
}