//
//  LedniceApp.swift
//  Lednice
//
//  Created by Martin Petr on 30.03.2023.
//

import SwiftUI
import CoreData

@main
struct LedniceApp: App {
    @StateObject private var manager: DataManager = DataManager()
    
    init() {
        NotificationManager.shared.requestAuthorization();
        
        // Seed the FoodItem entity with dummy data
        if isCoreDataEmpty(context: manager.context) {
            seedFoodItems(context: manager.context)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
                .environment(\.managedObjectContext, manager.context)
        }
    }
}
