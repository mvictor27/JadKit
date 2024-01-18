//
//  NonFetchedListTests.swift
//  JadKit
//
//  Created by Jad Osseiran on 3/5/16.
//  Copyright © 2016 Jad Osseiran. All rights reserved.
//

import UIKit
import XCTest

@testable import JadKit

class NonFetchedListTests: JadKitTests, NonFetchedList {
    typealias ListView = UIView
    typealias Cell = UIView
    typealias Object = TestObject
    
    func testObjectAtValidIndexPaths() {
        for section in 0..<listData.count {
            for row in 0..<listData[section].count {
                if let object = object(at: IndexPath(row: row, section: section)) {
                    XCTAssertEqual(object, listData[section][row])
                } else {
                    XCTFail()
                }
            }
        }
    }
    
    func testNumberOfRowsAndSetions() {
        XCTAssertEqual(numberOfSections, listData.count)
        
        for section in 0..<listData.count {
            XCTAssertEqual(numberOfRows(inSection: section), listData[section].count)
        }
    }
    
    func testValidIndexPath() {
        XCTAssertTrue(isValid(IndexPath(row: 0, section: 1)))
    }
    
    func testInvalidIndexPath() {
        XCTAssertFalse(isValid(IndexPath(row: 1, section: 10)))
    }
    
    func testObjectAtIndexPathSectionTooBig() {
        XCTAssertNil(object(at: IndexPath(row: 0, section: 2)))
    }
    
    func testObjectAtIndexPathSectionTooSmall() {
        XCTAssertNil(object(at: IndexPath(row: 0, section: -1)))
    }
    
    func testObjectAtIndexPathRowTooBig() {
        XCTAssertNil(object(at: IndexPath(row: 10, section: 0)))
    }
    
    func testObjectAtIndexPathRowTooSmall() {
        XCTAssertNil(object(at: IndexPath(row: -1, section: 0)))
    }
    
    // MARK: Conformance
    
    func cellIdentifier(for indexPath: IndexPath) -> String {
        return testReuseIdentifier
    }
    
    func listView(_ listView: ListView, configure cell: Cell, with anObject: Object,
                  at indexPath: IndexPath) { }
    
    func listView(_ listView: ListView, didSelect anObject: Object,
                  at indexPath: IndexPath) { }
}
