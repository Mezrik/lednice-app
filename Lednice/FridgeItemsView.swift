//
//  FridgeItemsView.swift
//  Lednice
//
//  Created by Martin Petr on 04.05.2023.
//

import SwiftUI

struct FridgeItemsView: View {
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.expiration, ascending: true)]
    )
    private var foodItems: FetchedResults<FoodItem>
    
    var unexpiredFoodItems: [FoodItem] {
        foodItems.filter { $0.expiration >= Date() }
    }
    
    var expiredFoodItems: [FoodItem] {
        foodItems.filter { $0.expiration < Date() }
    }
    
    @State var checked: Set<UUID> = Set()
    @State private var showingBulkActionSheet = false
    @State private var showingExpiredFoodItems = false
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Fridge items")
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
                if checked.count > 0 {
                    Button("Bulk actions") {
                        showingBulkActionSheet = true
                    }
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(14)
                    .actionSheet(isPresented: $showingBulkActionSheet) {
                        ActionSheet(title: Text("Are you sure you want to delete the item?"),
                            buttons: [
                            .destructive(Text("Delete"), action: {
                                manager.deleteFoodItemsByIDs(ids: Array(checked))
                                checked = Set()
                            }),
                            .cancel()
                        ])
                    }
                }
            }
            .frame(height: 57)
            
            if (expiredFoodItems.count > 0) {
                HStack {
                    Text("You have \(expiredFoodItems.count) expired item(s)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("View") {
                        showingExpiredFoodItems = true
                    }
                }
                .padding(.bottom, 15)
            }
            
            if unexpiredFoodItems.count > 0 {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(unexpiredFoodItems, id: \.self) { item in
                        FoodItemCard(foodItem: item, isChecked: checked.contains(item.id)) {
                            if checked.contains(item.id) {
                                checked.remove(item.id)
                            } else {
                                checked.insert(item.id)
                            }
                        }
                    }
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
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingExpiredFoodItems) {
            VStack {
                HStack {
                    Text("Expired fridge items")
                        .font(.system(size: 22, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Delete all") {
                        manager.deleteFoodItemsByIDs(ids: expiredFoodItems.map { $0.id })
                        showingExpiredFoodItems = false;
                    }
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.red)
                    .cornerRadius(14)
                }
                .padding(.bottom, 15)
                
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(expiredFoodItems, id: \.self) { item in
                        FoodItemCard(foodItem: item, isChecked: false) {}
                    }
                }
                Spacer()
            }.padding()
        }.navigationBarTitle("Fridge items")
    }
}

struct FridgeItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FridgeItemsView()
    }
}
