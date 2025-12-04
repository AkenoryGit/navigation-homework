//
//  CoreDataManager.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 05.09.2025.
//

import UIKit
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}

    // MARK: - Container (используем один контейнер из AppDelegate)

    private var persistentContainer: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }
        return appDelegate.persistentContainer
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Сохранение контекста

    func saveContext() {
        let context = self.context
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Ошибка при сохранении: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - FavoritePost (избранные посты по логину)

    /// Сохранить пост в избранное для конкретного логина
    func saveFavoritePost(from post: ProfilePost, for login: String) {
        let context = self.context

        // Если уже в избранном у данного пользователя – ничего не делаем
        if isFavorite(id: post.id, for: login) {
            return
        }

        let favorite = FavoritePost(context: context)
        favorite.id = post.id
        favorite.author = post.author
        favorite.text = post.description
        favorite.imageName = post.image
        favorite.login = login
        favorite.createdAt = Date()
        favorite.trackId = post.trackId

        saveContext()
        print("FavoritePost сохранён: id=\(post.id), login=\(login)")
    }

    /// Загрузить избранные посты для логина, с опциональным текстовым фильтром
    func fetchFavoritePosts(for login: String,
                            filterText: String? = nil) -> [FavoritePost] {

        let request: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        var predicates: [NSPredicate] = [
            NSPredicate(format: "login == %@", login)
        ]

        if let text = filterText, !text.isEmpty {
            let textPredicate = NSPredicate(
                format: "(author CONTAINS[cd] %@) OR (text CONTAINS[cd] %@)",
                text, text
            )
            predicates.append(textPredicate)
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Ошибка при получении избранных постов: \(error.localizedDescription)")
            return []
        }
    }

    /// Удалить пост из избранного для конкретного логина
    func deleteFavoritePost(with id: String, for login: String) {
        let request: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %@", id),
            NSPredicate(format: "login == %@", login)
        ])

        do {
            let results = try context.fetch(request)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Ошибка при удалении FavoritePost: \(error.localizedDescription)")
        }
    }

    /// Проверить, есть ли пост в избранном у конкретного пользователя
    func isFavorite(id: String, for login: String) -> Bool {
        let request: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "id == %@", id),
            NSPredicate(format: "login == %@", login)
        ])

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Ошибка при проверке избранного: \(error.localizedDescription)")
            return false
        }
    }
}
