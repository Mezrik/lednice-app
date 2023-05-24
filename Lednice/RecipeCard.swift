//
//  RecipeCard.swift
//  Lednice
//
//  Created by Martin Petr on 31.03.2023.
//

import SwiftUI

struct RecipeCard: View {
    var recipe: RecipeRecommendationDetail
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: recipe.image) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure(_):
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                    default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(11)
                .clipped()
            
            Text(recipe.title)
            
            Text("\(recipe.readyInMinutes) min")
                .foregroundColor(.gray)
        
            Link("View", destination: recipe.spoonacularSourceUrl!)
        }
    }
}

struct RecipeCard_Previews: PreviewProvider {
    static let recipe = RecipeRecommendationDetail(id: 716429, image: URL(string: "https://spoonacular.com/recipeImages/716429-556x370.jpg"), title: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs", readyInMinutes: 45, spoonacularSourceUrl: URL(string: "https://spoonacular.com/recipeImages/716429-556x370.jpg"))
    
    static var previews: some View {
        RecipeCard(recipe: recipe)
    }
}
