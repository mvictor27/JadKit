//
//  Size.swift
//  JadKit
//
//  Created by Jad Osseiran on 19/07/2014.
//  Copyright (c) 2015 Jad. All rights reserved.
//

import UIKit

public extension CGSize {
    public var floorSize: CGSize {
        return CGSize(width: floor(width), height: floor(height))
    }
    
    public var ceilSize: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }
}