//
//  DataManager.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//

import Foundation
import CoreData

class DataManager: NSObject, ObservableObject {
    
    @Published var foodItems: [FoodItem] = [FoodItem]()
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                 fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
    
    func deleteFoodItemsByIDs(ids: [UUID]) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FoodItem")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        
        do {
            let items = try context.fetch(fetchRequest) as? [NSManagedObject]
            for item in items ?? [] {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}

