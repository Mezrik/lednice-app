//
//  RecipeRecommendationDetail.swift
//  Lednice
//
//  Created by Martin Petr on 24.05.2023.
//

import Foundation

struct RecipeRecommendationDetail: Decodable, Identifiable, Hashable {
    var id: Int
    var image: URL?
    var title: String
    var readyInMinutes: Int
    var spoonacularSourceUrl: URL?
}
