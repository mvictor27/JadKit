//
//  PageViewController.swift
//  JadKit
//
//  Created by Jad Osseiran on 29/05/2015.
//  Copyright (c) 2015 Jad Osseiran. All rights reserved.
//

import UIKit

public class PageContentViewController: UIViewController {
    var pageNumber: UInt = 0

    var contentObject: AnyObject? {
        didSet {
            didUpdateContentObject()
        }
    }

    func didUpdateContentObject() { }
}

public class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /// The current view controller shown on the screen.
    /// You can use KVO to safely observe this property.
    public private(set) var currentContentViewController: PageContentViewController! {
        willSet {
            willChangeValueForKey("currentContentViewController")
        }
        didSet {
            didChangeValueForKey("currentContentViewController")
        }
    }

    /// The current content object which is dispalyed on screen. This object can be
    /// used to help populate the currentContentViewController.
    public var currentContentObject: AnyObject? {
        return currentContentViewController.contentObject
    }

    /// The index of the displayed page.
    /// You can use KVO to safely observe this property.
    public var currentIndex: UInt = 0 {
        willSet {
            willChangeValueForKey("currentIndex")
        }
        didSet {
            didChangeValueForKey("currentIndex")
        }
    }

    /// The initial page to load on initialisation.
    public var initialPageIndex: UInt = 0

    /// The number of pages the controller will have to deal with.
    public var numberOfPages: UInt = 0

    /// Flag to lock to the swiping of pages.
    public var swipeLock = false {
        didSet {
            // Disable the scroll view because page view controllers really suck.
            for subview in view.subviews {
                if subview is UIScrollView {
                    let scrollView = subview as! UIScrollView
                    scrollView.scrollEnabled = swipeLock == false
                    return
                }
            }
        }
    }

    /// Used to keep track of the content view controllers and their respective indices.
    private var contentViewControllers = NSMapTable(keyOptions: NSMapTableWeakMemory, valueOptions: NSMapTableWeakMemory)

    private var beforeViewController: PageContentViewController?

    private var afterViewController: PageContentViewController?

    public convenience init(initialPageIndex: UInt, navigationOrientation: UIPageViewControllerNavigationOrientation) {
        self.init(transitionStyle: .Scroll, navigationOrientation: navigationOrientation, options: nil)

        self.initialPageIndex = initialPageIndex
        self.dataSource = self
        self.delegate = self
    }

    // MARK: View Lifecycle

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        initialPageIndex = currentIndex
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if numberOfPages > 0 {
            // Create the initial view contorller from the given controller identifiers.
            if let viewController = viewControllerAtIndex(initialPageIndex) {
                setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
            }
        }
    }

    // MARK: Abstract Methods

    /**
     *  The class for the page number to initialise at run time.
     *
     *  - parameter pageNumber: The page number at which the class will be initialised.
     *
     *  - returns: the class to be initialised
     */
    public func classTypeForPageAtIndex(index: UInt) -> PageContentViewController.Type! {
        return nil
    }

    /**
     *  The content object to help provide context to the currentContentViewController
     *
     *  - parameter pageNumber: The page number for the content object.
     *
     *  - returns: The content object at the given page.
     */
    public func contentObjectForPageAtIndex(index: UInt) -> AnyObject! {
        return nil
    }

    public func pageViewWillPrepareViewController(controller: PageContentViewController) { }

    /**
     *  Method to override to allow subclasses to manipulate the controller object before it
     *  is fed back in the page view controller.
     *
     *  - parameter viewController: The view controller to manipulate.
     */
    public func pageViewWillSetViewController(controller: PageContentViewController) { }

    /**
     *  Called when the page view controller has successfully changed.
     */
    public func pageViewDidSwipe() {
        // Set the controller so that any objects observing this keypath get properly notified.
        currentContentViewController = viewControllers?.last as? PageContentViewController
    }

    // MARK: Logic

    /**
     *  Method to jump to a certain page in the page view controller. Solution
     *  courtesy of http://stackoverflow.com/questions/13633059/uipageviewcontroller-how-do-i-correctly-jump-to-a-specific-page-without-messing
     *
     *  - parameter pageNumber: The page number to jump to.
     *  - parameter direction: The dirrection of the jump.
     *  - parameter animated: Wether the jump is animated or not.
     */
    private func jumpToPageIndex(pageIndex: UInt, withDirection direction: UIPageViewControllerNavigationDirection, animate: Bool) {
        // Create the initial view contorller from the given controller identifiers.
        let viewController = classTypeForPageAtIndex(pageIndex)()

        let neighbourViewController: PageContentViewController?

        if direction == .Forward {
            neighbourViewController = dataSource?.pageViewController(self, viewControllerBeforeViewController: viewController) as? PageContentViewController
        } else {
            neighbourViewController = dataSource?.pageViewController(self, viewControllerAfterViewController: viewController) as? PageContentViewController
        }

        if let controller = neighbourViewController {
            weak var weakSelf = self
            setViewControllers([controller], direction: direction, animated: false) { finished in
                weakSelf?.setViewControllers([controller], direction: direction, animated: animate, completion: nil)
            }
        }
    }

    /**
     *  Jumps to the given page number and swipes to the corresponding page.
     *
     *  - parameter pageNumber: The index to set.
     *  - parameter animated: Wether the change is animated.
     */
    public func jumpToPageIndex(pageIndex: UInt, animated: Bool) {
        if pageIndex == currentIndex || pageIndex >= numberOfPages {
            return
        }

        let direction: UIPageViewControllerNavigationDirection = currentIndex < pageIndex ? .Forward : .Reverse

        currentIndex = pageIndex

        jumpToPageIndex(pageIndex, withDirection: direction, animate: animated)

        pageViewDidSwipe()
    }

    /**
     *  Drops the before and after controllers.
     */
    public func dropSideViewControllers() {
        beforeViewController = nil
        afterViewController = nil
    }

    private func viewControllerAtIndex(index: UInt) -> PageContentViewController? {
        // If the number of identifiers is invalid return nil.
        if numberOfPages == 0 || index >= numberOfPages {
            return nil
        }

        // Instantiate the view controller and set its page index.
        let viewController = classTypeForPageAtIndex(index)()
        pageViewWillPrepareViewController(viewController)

        let contentObject: AnyObject! = contentObjectForPageAtIndex(index)

        contentViewControllers.setObject(index, forKey: viewController)

        viewController.contentObject = contentObject
        viewController.pageNumber = index

        pageViewWillSetViewController(viewController)

        return viewController
    }

    // MARK: Page View Controller

    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! PageContentViewController
        var index: UInt = pageContentViewController.pageNumber

        if index == 0 {
            return nil
        }

        --index
        beforeViewController = viewControllerAtIndex(index)
        return beforeViewController
    }

    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let pageContentViewController = viewController as! PageContentViewController
        var index: UInt = pageContentViewController.pageNumber

        if index >= numberOfPages {
            return nil
        }

        ++index
        afterViewController = viewControllerAtIndex(index)
        return afterViewController
    }

    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            pageViewDidSwipe()
        }
    }
}
