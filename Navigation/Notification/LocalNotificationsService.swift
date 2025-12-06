//
//  LocalNotificationsService.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 27.10.2025.
//

import UIKit
import UserNotifications

class LocalNotificationsService {
    func registeForLatestUpdatesIfPossible() {

        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.sound, .badge, .alert]
        
        center.requestAuthorization(options: options) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
                
                let content = UNMutableNotificationContent()
                content.title = "Обновления"
                content.body = "Посмотрите последние обновления"
                content.sound = UNNotificationSound.default
                content.badge = 1
                
                var dateComponents = DateComponents()
                dateComponents.hour = 19
                dateComponents.minute = 0

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: dateComponents,
                    repeats: true
                )
                
                let request = UNNotificationRequest(
                    identifier: "dailyUpdates",
                    content: content,
                    trigger: trigger
                )
                
                center.add(request) { error in
                    if let error = error {
                        print("Ошибка при регистрации уведомления: \(error.localizedDescription)")
                    } else {
                        print("Уведомление зарегистрировано успешно")
                    }
                }
            } else {
                print("Разрешение на уведомления не получено: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            }
        }
    }
}
