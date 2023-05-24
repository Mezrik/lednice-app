//
//  AddNewItemViewModel.swift
//  Lednice
//
//  Created by Martin Petr on 24.05.2023.
//

import Foundation
import UIKit

class AddNewItemViewModel: ObservableObject {
    @Published var name: String
    @Published var date: Date
    @Published var thumbnail: UIImage?
    
    init(foodItem: FoodItem?) {
        if let item = foodItem {
            self.name = item.name
            self.date = item.expiration
            
            if let thumbnail = item.thumbnail,
               let imageData = try? Data(contentsOf: thumbnail),
               let image = UIImage(data: imageData) {
                self.thumbnail = image
            }
        } else {
            self.name = ""
            self.date = Date()
        }
    }
}
