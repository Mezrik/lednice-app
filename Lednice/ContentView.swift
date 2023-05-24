//
//  ContentView.swift
//  Lednice
//
//  Created by Martin Petr on 30.03.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.expiration, ascending: true)]
    )
    private var foodItems: FetchedResults<FoodItem>
        
    @State private var recipesRecommendations: [RecipeRecommendationDetail]? = nil
    
    var unexpiredFoodItems: [FoodItem] {
        foodItems.filter { $0.expiration >= Date() }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Expires soon")
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    Spacer()
                    NavigationLink {
                        AddNewItemView(foodItem: nil)
                    } label: {
                        Label("Add item", systemImage: "plus.circle")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .lineSpacing(22)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(14)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if (unexpiredFoodItems.count > 0)
                        {
                            // List of items with spacing
                            ForEach(unexpiredFoodItems.prefix(4)) { item in
                                FoodItemCard(foodItem: item, isChecked: false) {}
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("No fresh items in the fridge")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 20)
                                Spacer()
                            }
                        }
                        
                        NavigationLink {
                            FridgeItemsView()
                        } label: {
                            Label("Manage fridge items", systemImage: "plus.circle")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .lineSpacing(22)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(14)
                        
                        Text("Cook something tasty")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                        
                        let layout = [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]
                        
                        if (unexpiredFoodItems.count > 0)
                        {
                            if let recipes = recipesRecommendations {
                                if recipes.count <= 0 {
                                    HStack {
                                        Spacer()
                                        Text("No recipes found")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                            .padding(.vertical, 20)
                                        Spacer()
                                    }
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                            
                            LazyVGrid(columns: layout, spacing: 10) {
                                if let recipes = recipesRecommendations {
                                    ForEach(recipes, id: \.self) { recipe in
                                        RecipeCard(recipe: recipe)
                                            .aspectRatio(1, contentMode: .fit)
                                    }
                                }
                            }
                            .task {
                                do {
                                    if let result = try await fetchRecipeDetails(items: unexpiredFoodItems) {
                                        recipesRecommendations = result
                                    }
                                } catch {
                                    recipesRecommendations = []
                                    print(error)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .alignmentGuide(.top, computeValue: { d in d[.top] })
        }
    }
    
    func fetchRecipes(items: [FoodItem]) async throws -> [RecipeRecommendation]? {
        let titles = items.map { $0.name }
        let ingredients = titles.joined(separator: ",")
        
        var urlComponents = URLComponents(string: "https://api.spoonacular.com/recipes/findByIngredients")!

        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            let queryItems = [URLQueryItem(name: "ingredients", value: ingredients), URLQueryItem(name: "apiKey", value: apiKey), URLQueryItem(name: "number", value: "4")]

            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                print("Invalid URL")
                return nil
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([RecipeRecommendation].self, from: data)
            
            return decodedData
        }
        
        return []
    }
    
    func fetchRecipeDetails(items: [FoodItem]) async throws -> [RecipeRecommendationDetail]? {
        let recipes = try await fetchRecipes(items: items);
        
        let ids = recipes?.map({ "\($0.id)" }).joined(separator: ",")
        
        var urlComponents = URLComponents(string: "https://api.spoonacular.com/recipes/informationBulk")!

        if let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String {
            let queryItems = [URLQueryItem(name: "ids", value: ids), URLQueryItem(name: "apiKey", value: apiKey)]
            
            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                print("Invalid URL")
                return nil
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode([RecipeRecommendationDetail].self, from: data)
            
            return decodedData
        }
        
        return []
    }
}

struct ContentView_Previews: PreviewProvider {
    static let previewContext = createPreviewContext()
    
    static var previews: some View {
        
        return ContentView()
            .previewDevice("iPhone 13")
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0xff00) >> 8) / 255.0
        let b = Double(rgbValue & 0xff) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
