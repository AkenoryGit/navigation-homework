//
//  CoreDataManager.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 05.09.2025.
//

import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    private let modelName = "FavoritePostModel"

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Ошибка при загрузке хранилища: \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Ошибка при сохранении: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func saveFavoritePost(id: String, author: String, text: String, imageName: String, createdAt: Date) {
        let post = FavoritePost(context: context)
        post.id = id
        post.author = author
        post.text = text
        post.imageName = imageName
        post.createdAt = createdAt
        saveContext()
    }

    func fetchFavoritePosts() -> [FavoritePost] {
        let fetchRequest: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка при получении избранных постов: \(error.localizedDescription)")
            return []
        }
    }

    func deleteFavoritePost(with id: String) {
        let fetchRequest: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            saveContext()
        } catch {
            print("Ошибка при удалении поста: \(error.localizedDescription)")
        }
    }

    func isFavorite(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка при проверке избранного: \(error.localizedDescription)")
            return false
        }
    }
}
