//
//  NotificationManager.swift
//  Lednice
//
//  Created by Martin Petr on 24.05.2023.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }

    func scheduleNotification(for foodItem: FoodItem) {
        let content = UNMutableNotificationContent()
        content.title = "Food Expiration Reminder"
        content.body = "\(foodItem.name) is going to expire soon!"
        content.sound = .default

        guard let date = Calendar.current.date(byAdding: .day, value: -1, to: foodItem.expiration) else { return }
        var triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        triggerDate.hour = 9
        triggerDate.minute = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: foodItem.id.uuidString, content: content, trigger: trigger)

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
