//
//  Seed.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//

import CoreData

func isCoreDataEmpty(context: NSManagedObjectContext) -> Bool {
    let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()

    do {
        let itemCount = try context.count(for: fetchRequest)
        return itemCount == 0
    } catch {
        print("Error checking Core Data count: \(error.localizedDescription)")
        return false
    }
}

func seedFoodItems(context: NSManagedObjectContext) {
    let foodItems = [
        (name: "Milk", expiration: Date().addingTimeInterval(3600 * 24 * 7), thumbnail: URL(string: "https://upload.wikimedia.org/wikipedia/commons/9/9c/Bottle_of_milk.jpg")),
        (name: "Bread", expiration: Date().addingTimeInterval(3600 * 24 * 5), thumbnail: URL(string: "https://www.kitchensanctuary.com/wp-content/uploads/2020/06/Artisan-Bread-square-FS-46-500x500.jpg")),
        (name: "Cheese", expiration: Date().addingTimeInterval(3600 * 24 * 10), thumbnail: URL(string: "https://img1.10bestmedia.com/Images/Photos/385140/GettyImages-531048911_55_660x440.jpg"))
    ]

    for foodItem in foodItems {
        let newFoodItem = FoodItem(context: context)
        newFoodItem.id = UUID()
        newFoodItem.name = foodItem.name
        newFoodItem.expiration = foodItem.expiration
        newFoodItem.thumbnail = foodItem.thumbnail
    }

    do {
        try context.save()
    } catch {
        print("Error seeding data: \(error.localizedDescription)")
    }
}
