//
//  Persistence.swift
//  Shared
//
//  Created by Felipe Ferrari [EXT] on 23/12/22.
//

import CoreData
import SwiftUI

protocol PersistenceControllerProtocol {
    var downloadedPages: Int { get set }
    var container: NSPersistentContainer { get }
    func save() throws
    func fetch<Class: NSManagedObject>(id: Int?, keyPath: String?) throws -> [Class]
    func clearDatabase()
}

protocol RickAndMortyIdentifiable {
    var identifier: Int { get }
}

typealias PersistenceRequest<Class: NSManagedObject> = NSFetchRequest<Class> where Class: RickAndMortyIdentifiable

enum PersistenceError: InternalError {
    case CouldNotSaveToCoreData
    case couldNotFetchFromCoreData

    var description: String {
        switch self {
        case .CouldNotSaveToCoreData: return "Could not save to Core Data"
        case .couldNotFetchFromCoreData: return "Could not fetch from Core Data"
        }
    }
}

struct PersistenceController: PersistenceControllerProtocol {
    static let shared = PersistenceController()
    @AppStorage("downloadedPages") var downloadedPages = 0

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "RickAndMortyCastApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Fail to create CoreData Stack \(error.localizedDescription)")
            } else {
                print("CoreData Stack set up with persistent store type")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func fetch<Class: NSManagedObject>(id: Int? = nil, keyPath: String? = nil) throws -> [Class] {
        if let fetch: NSFetchRequest<Class> = Class.fetchRequest() as? NSFetchRequest<Class> {
            if let id = id, let keyPath = keyPath {
                let idPredicate = NSPredicate(format: "%K == %i", keyPath, id)
                fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate])
            }

            return try container.viewContext.fetch(fetch)
        } else {
            throw PersistenceError.couldNotFetchFromCoreData
        }
    }

    func save() throws {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw PersistenceError.CouldNotSaveToCoreData
            }
        }
    }

    func clearDatabase() {
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
