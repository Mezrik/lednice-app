//
//  RecipeItem.swift
//  Lednice
//
//  Created by Martin Petr on 31.03.2023.
//

import Foundation

struct RecipeItem: Identifiable {
    var id = UUID()
    var name: String
    var cookingTime: Int
    var thumbnail: URL?
}
