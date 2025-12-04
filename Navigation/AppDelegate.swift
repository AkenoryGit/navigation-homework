//
//  AppDelegate.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit
import Firebase
import FirebaseCore
import CoreData
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let notificationsService = LocalNotificationsService()
    
    // MARK: - Core Data

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoritePostModel")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Ошибка при загрузке хранилища: \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - UIApplicationDelegate

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Настраиваем Realm
        let config = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true
        )
        Realm.Configuration.defaultConfiguration = config

        // Firebase + локальные уведомления
        FirebaseApp.configure()
        notificationsService.registeForLatestUpdatesIfPossible()

        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}

