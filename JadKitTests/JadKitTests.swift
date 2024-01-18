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
    let bundles = [Bundle(for: JadKitTests.self)]
    guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
        fatalError("Model not found")
    }
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    try! persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                       configurationName: nil, at: nil, options: nil)
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    testManagedObjectContext = managedObjectContext
}

private func tearDownCoreData() {
    testManagedObjectContext.reset()
    
    let fetchRequest = NSFetchRequest<TestObject>()
    
    do {
        let fetchedObjects = try testManagedObjectContext.fetch(fetchRequest)
        for fetchedObject in fetchedObjects {
            testManagedObjectContext.delete(fetchedObject)
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
    
    var fetchedResultsController: NSFetchedResultsController<TestObject>!
    
    override func setUp() {
        super.setUp()
        
        setUpCoreData()
        
        listData = [[TestObject(color: UIColor.blue), TestObject(color: UIColor.white),
                     TestObject(color: UIColor.red)], [TestObject(color: UIColor.black)]]
        
        let fetchRequest = NSFetchRequest<TestObject>(entityName: TestObject.entityName)
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
    
    func insertAndSaveObjects(_ numObjects: Int, sectionName: String) {
        for _ in 0..<numObjects {
            let color: UIColor
            let randomInt = arc4random_uniform(4)
            switch randomInt {
                case 0:
                    color = UIColor.red
                    
                case 1:
                    color = UIColor.blue
                    
                case 2:
                    color = UIColor.green
                    
                default:
                    // I love yellow.
                    color = UIColor.yellow
            }
            
            insertObject(color: color, sectionName: sectionName)
        }
        
        saveCoreData()
    }
    
    func addAndSaveObject(color: UIColor, sectionName: String) {
        insertObject(color: color, sectionName: sectionName)
        saveCoreData()
    }
    
    func updateAndSaveObject(forName name: String, updateClosure: (TestObject) -> Void) {
        let request = NSFetchRequest<TestObject>(entityName: TestObject.entityName)
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            guard let foundObject = try testManagedObjectContext.fetch(request).first else {
                XCTFail()
                return
            }
            
            // Let the updater do its thing.
            updateClosure(foundObject)
            // Save after the update.
            saveCoreData()
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    func deleteAndSaveObject(_ object: TestObject) {
        testManagedObjectContext.delete(object)
        saveCoreData()
    }
    
    func deleteAndSaveSectionName(_ sectionName: String) {
        let request = NSFetchRequest<TestObject>(entityName: TestObject.entityName)
        request.predicate = NSPredicate(format: "sectionName == %@", sectionName)
        
        do {
            let foundObjects = try testManagedObjectContext.fetch(request)
            for foundObject in foundObjects {
                testManagedObjectContext.delete(foundObject)
            }
            
            saveCoreData()
        } catch let error {
            XCTFail("\(error)")
        }
    }
    
    private func insertObject(color: UIColor, sectionName: String) {
        let object = NSEntityDescription.insertNewObject(forEntityName: TestObject.entityName,
                                                         into: testManagedObjectContext) as! TestObject
        
        object.name = NSUUID().uuidString
        object.sectionName = sectionName
        object.color = color
    }
}

class TestObject: NSManagedObject {
    @NSManaged var name: String
    @NSManaged var color: UIColor
    @NSManaged var sectionName: String?
    
    class var entityName: String {
        return "TestObject"
    }
    
    private class var entityDescription: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName,
                                          in: testManagedObjectContext)!
    }
    
    convenience init(color: UIColor) {
        self.init(entity: TestObject.entityDescription, insertInto: nil)
        
        self.name = NSUUID().uuidString
        self.color = color
    }
}
