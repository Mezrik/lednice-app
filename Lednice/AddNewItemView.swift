//
//  AddNewItemView.swift
//  Lednice
//
//  Created by Martin Petr on 23.05.2023.
//

import SwiftUI
import UIKit
import CoreData

struct AddNewItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    var itemId: UUID?
    
    @ObservedObject var viewModel: AddNewItemViewModel
    
    @State private var showingImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    init(foodItem: FoodItem?) {
        itemId = foodItem?.id
        viewModel = AddNewItemViewModel(foodItem: foodItem)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Item details")) {
                TextField("Write item name", text: $viewModel.name)
                DatePicker("Pick a Date", selection: $viewModel.date, displayedComponents: .date)
                Button(action: {
                    self.showingImagePicker = true
                }, label: {
                    HStack {
                        Image(systemName: "photo")
                        Text("Upload thumbnail image")
                    }
                })
                
                Button(action: {
                    self.imagePickerSource = .camera
                    self.showingImagePicker = true
                }, label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take a photo")
                    }
                })
            }
            
            if let thumbnail = viewModel.thumbnail {
                Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
            }
            
            Section {
                Button(action: {
                    self.save()
                }, label: {
                    Text("Save item")
                })
            }
        }
        .navigationBarTitle("Add fridge item")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.thumbnail, sourceType: self.imagePickerSource)
        }
    }
    
    func save() {
        if let id = self.itemId {
            self.update(id: id)
        } else {
            let item = FoodItem(context: viewContext)
            
            item.id = UUID()
            item.name = viewModel.name
            item.expiration = viewModel.date
            item.thumbnail = saveThumbnail()
            
            do {
                try viewContext.save()
                
                NotificationManager.shared.scheduleNotification(for: item)
            } catch {
                print("Failed to save item: \(error)")
            }
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func update(id: UUID) {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let objects = try viewContext.fetch(fetchRequest)
            if let item = objects.first {
                item.name = viewModel.name
                item.expiration = viewModel.date
                item.thumbnail = saveThumbnail()

                do {
                    try viewContext.save()
                } catch {
                    print("Error: couldn't save the context \(error)")
                }
            }
        } catch {
            print("Error: couldn't fetch the required object \(error)")
        }
    }
    
    private func saveThumbnail() -> URL? {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        let fileName = UUID().uuidString
        let fileURL = directory.appendingPathComponent(fileName)
        if let data = viewModel.thumbnail?.jpegData(compressionQuality: 1.0),
            let _ = try? data.write(to: fileURL) {
            return fileURL;
        }
        
        return nil
    }
}


struct AddNewItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewItemView(foodItem: nil)
    }
}
