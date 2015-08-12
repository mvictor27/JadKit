//
//  CircleImageView.swift
//  JadKit
//
//  Created by Jad Osseiran on 11/01/2015.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit

public class CircleImageView: UIImageView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.maskToCircle()
    }
    
    convenience public init() {
        self.init(frame: CGRectZero)
    }
    
    convenience public init(size: CGSize) {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        maskToCircle()
    }
}
