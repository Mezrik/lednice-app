//
//  FoodItem+CoreDataProperties.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//
//

import Foundation
import CoreData


extension FoodItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodItem> {
        return NSFetchRequest<FoodItem>(entityName: "FoodItem")
    }

    @NSManaged public var expiration: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var thumbnail: URL?

}

extension FoodItem : Identifiable {

}
