//
//  FoodItem.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//

import Foundation

struct FoodItdem: Identifiable {
    var id = UUID()
    var name: String
    var expiration: Date
    var thumbnail: URL?
}
