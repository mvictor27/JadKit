//
//  ViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 8/15/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import UIKit

public extension UIViewController {
    public var modal: Bool {
        if self.presentingViewController?.presentedViewController == self {
            return true
        }
        // UINavigationController
        if self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            return true
        }
        // UITabBarController
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        return false
    }
}
