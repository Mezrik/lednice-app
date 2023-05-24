//
//  PreviewHelpers.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//

import CoreData

func createPreviewContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    if let modelURL = Bundle.main.url(forResource: "LedniceApp", withExtension: "momd"),
       let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            fatalError("Unable to add persistent store: \(error.localizedDescription)")
        }

        context.persistentStoreCoordinator = persistentStoreCoordinator
    } else {
        fatalError("Unable to load managed object model")
    }

    return context
}
