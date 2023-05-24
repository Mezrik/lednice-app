//
//  FoodItemCard.swift
//  Lednice
//
//  Created by Martin Petr on 31.03.2023.
//

import SwiftUI

struct FoodItemCard: View {
    @EnvironmentObject var manager: DataManager
    
    var action: () -> Void
    var foodItem: FoodItem
    var isChecked: Bool
    
    @State private var showingActionSheet = false
    @State private var showingFoodItemEditSheet = false;
    
    init(foodItem: FoodItem, isChecked: Bool?, action: @escaping () -> Void) {
        self.foodItem = foodItem
        self.isChecked = isChecked ?? false
        self.action = action
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    var body: some View {
        HStack() {
            ZStack {
                AsyncImage(url: foodItem.thumbnail) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray)
                    default:
                        Rectangle()
                            .fill(Color.gray)
                    }
                }
                .frame(width: 80, height: 80)
                .clipped()
                
                if isChecked {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.7)
                    
                    Image(systemName: "checkmark.circle.fill") // Checkbox image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                }
            }
            .onTapGesture {
                action()
            }
            
            VStack(alignment: .leading) {
                Text(foodItem.name)
                    .font(.title3)
                if foodItem.expiration < Date() {
                    Text("Expired \(foodItem.expiration, formatter: Self.dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    Text("Will expire \(foodItem.expiration, formatter: Self.dateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
            .foregroundColor(.black)
            .padding(10)
            
            Spacer()
            
            Button(action: {
                showingActionSheet = true
            }, label: {
                Image(systemName: "ellipsis")
            })
            .padding(20)
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(title: Text("Options"), buttons: [
                    .default(Text("Edit"), action: {
                        showingFoodItemEditSheet = true
                    }),
                    .destructive(Text("Delete"), action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            manager.deleteFoodItemsByIDs(ids: [foodItem.id])
                        }
                    }),
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingFoodItemEditSheet) {
                AddNewItemView(foodItem: self.foodItem)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(0)
        .background(Color.init(hex: "E4E4E4"))
        .cornerRadius(11)
    }
}

struct FoodItemCard_Previews: PreviewProvider {    
    static let previewContext = DataManager.persistentContainer.viewContext;
    
    static var previews: some View {
        let foodItem = FoodItem(context: previewContext)

        foodItem.name = "Caplansky’s Spicy Mustard"
        foodItem.expiration = Date()
        foodItem.thumbnail = URL(string: "https://placekitten.com/80/80")
        foodItem.id = UUID()
        
        return FoodItemCard(foodItem: foodItem, isChecked: true) {}
    }
}
