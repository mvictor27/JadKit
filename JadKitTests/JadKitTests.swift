//
//  JadKitTests.swift
//  JadKitTests
//
//  Created by Jad Osseiran on 29/05/2015.
//  Copyright (c) 2016 Jad Osseiran. All rights reserved.
//

import CoreData
import UIKit
import XCTest

let testReuseIdentifier = "Identifier"

private(set) var testManagedObjectContext: NSManagedObjectContext!

private func setUpCoreData() {
  let bundles = [NSBundle(forClass: JadKitTests.self)]
  guard let model = NSManagedObjectModel.mergedModelFromBundles(bundles) else {
    fatalError("Model not found")
  }

  let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
  try! persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
    configuration: nil, URL: nil, options: nil)

  let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
  managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

  testManagedObjectContext = managedObjectContext
}

private func tearDownCoreData() {
  testManagedObjectContext.reset()

  let fetchRequest = NSFetchRequest(entityName: TestObject.entityName)

  do {
    let fetchedObjects = try testManagedObjectContext.executeFetchRequest(fetchRequest)
      as! [TestObject]
    for fetchedObject in fetchedObjects {
      testManagedObjectContext.deleteObject(fetchedObject)
    }
  } catch let error {
    XCTFail("\(error)")
  }

  saveCoreData()
}

private func saveCoreData() {
  do {
    try testManagedObjectContext.save()
  } catch let error {
    XCTFail("\(error)")
  }
}

class JadKitTests: XCTestCase {
  var listData: [[TestObject]]!

  var fetchedResultsController: NSFetchedResultsController!

  override func setUp() {
    super.setUp()

    setUpCoreData()

    listData = [[TestObject(color: UIColor.blueColor()), TestObject(color: UIColor.whiteColor()),
      TestObject(color: UIColor.redColor())], [TestObject(color: UIColor.blackColor())]]

    let fetchRequest = NSFetchRequest(entityName: TestObject.entityName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sectionName", ascending: true)]
    fetchRequest.predicate = NSPredicate(value: true)

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: testManagedObjectContext, sectionNameKeyPath: "sectionName",
      cacheName: nil)
  }

  override func tearDown() {
    tearDownCoreData()

    super.tearDown()
  }

  func performFetch() {
    do {
      try fetchedResultsController.performFetch()
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func insertAndSaveObjects(numObjects: Int, sectionName: String) {
    for _ in 0..<numObjects {
      let color: UIColor
      let randomInt = arc4random_uniform(4)
      switch randomInt {
      case 0:
        color = UIColor.redColor()

      case 1:
        color = UIColor.blueColor()

      case 2:
        color = UIColor.greenColor()

      default:
        // I love yellow.
        color = UIColor.yellowColor()
      }

      insertObject(color, sectionName: sectionName)
    }

    saveCoreData()
  }

  func addAndSaveObject(color: UIColor, sectionName: String) {
    insertObject(color, sectionName: sectionName)
    saveCoreData()
  }

  func updateAndSaveObject(forName name: String, updateClosure: (object: TestObject) -> Void) {
      let request = NSFetchRequest(entityName: TestObject.entityName)
      request.predicate = NSPredicate(format: "name == %@", name)

      do {
        guard let foundObject = try testManagedObjectContext.executeFetchRequest(request).first
          as? TestObject else {
            XCTFail()
            return
        }

        // Let the updater do its thing.
        updateClosure(object: foundObject)
        // Save after the update.
        saveCoreData()
      } catch let error {
        XCTFail("\(error)")
      }
  }

  func deleteAndSaveObject(object: TestObject) {
    testManagedObjectContext.deleteObject(object)
    saveCoreData()
  }

  func deleteAndSaveSection(sectionName: String) {
    let request = NSFetchRequest(entityName: TestObject.entityName)
    request.predicate = NSPredicate(format: "sectionName == %@", sectionName)

    do {
      guard let foundObjects = try testManagedObjectContext.executeFetchRequest(request)
        as? [TestObject] else {
          XCTFail()
          return
      }

      for foundObject in foundObjects {
        testManagedObjectContext.deleteObject(foundObject)
      }

      saveCoreData()
    } catch let error {
      XCTFail("\(error)")
    }
  }

  private func insertObject(color: UIColor, sectionName: String) {
    let object = NSEntityDescription.insertNewObjectForEntityForName(TestObject.entityName,
      inManagedObjectContext: testManagedObjectContext) as! TestObject

    object.name = NSUUID().UUIDString
    object.sectionName = sectionName
    object.color = color
  }
}

class TestObject: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var color: UIColor
  @NSManaged var sectionName: String?

  private class var entityName: String {
    return "TestObject"
  }

  private class var entityDescription: NSEntityDescription {
    return NSEntityDescription.entityForName(entityName,
      inManagedObjectContext: testManagedObjectContext)!
  }

  convenience init(color: UIColor) {
    self.init(entity: TestObject.entityDescription, insertIntoManagedObjectContext: nil)

    self.name = NSUUID().UUIDString
    self.color = color
  }
}
