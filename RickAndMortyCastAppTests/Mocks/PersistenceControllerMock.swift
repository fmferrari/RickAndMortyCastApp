//
//  PersistenceControllerMock.swift
//  Tests iOS
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

import CoreData
@testable import RickAndMortyCastApp

class PersistenceControllerMock: PersistenceControllerProtocol {

    static let shared = PersistenceControllerMock()

    var downloadedPages: Int = 0
    var container: NSPersistentContainer
    var saveWasCalled: Bool = false
    var fetchWasCalled: Bool = false
    var clearWasCalled: Bool = false
    var returnValue: [NSManagedObject] = []
    var error: Error?

    init() {
        container = PersistenceControllerMock.setupContainer()
    }

    func reset() {
        downloadedPages = 0
        returnValue = []
        saveWasCalled = false
        fetchWasCalled = false
        error = nil
        container = PersistenceControllerMock.setupContainer()
    }

    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CharacterItem.self)

        guard let url = bundle.url(forResource: "RickAndMortyCastApp", withExtension: "momd") else {
            fatalError("Failed to locate momd file for xcdatamodeld")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for xcdatamodeld")
        }

        return model
    }()

    static func setupContainer() -> NSPersistentContainer {
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("store")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.shouldAddStoreAsynchronously = false
        description.type = NSInMemoryStoreType

        let persistentContainer = NSPersistentContainer(name: "RickAndMortyCastApp", managedObjectModel: PersistenceControllerMock.managedObjectModel)
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fail to create CoreData Stack \(error.localizedDescription)")
            } else {
                print("CoreData Stack set up with in-memory store type")
            }
        }
        return persistentContainer
    }

    func fetch<Class: NSManagedObject>(id: Int?, keyPath: String?) throws -> [Class]  {
        fetchWasCalled = true
        if let error = error {
            throw error
        }
        return returnValue as! [Class]
    }

    func save() throws {
        saveWasCalled = true
        try container.viewContext.save()
        if let error = error {
            throw error
        }
    }

    func clearDatabase() {
        clearWasCalled = true
        guard let url = container.persistentStoreDescriptions.first?.url else { return }

        let persistentStoreCoordinator = container.persistentStoreCoordinator

         do {
             try persistentStoreCoordinator.destroyPersistentStore(at:url, ofType: NSSQLiteStoreType, options: nil)
             try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
         } catch {
             print("Attempted to clear persistent store: " + error.localizedDescription)
         }
    }
}
