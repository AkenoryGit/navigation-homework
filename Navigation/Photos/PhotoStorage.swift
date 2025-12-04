//
//  PhotoStorage.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

/// Хранилище пользовательских фотографий (по логину)
final class PhotoStorage {

    static let shared = PhotoStorage()

    private init() {}

    // MARK: - Model

    struct StoredPhoto: Codable, Equatable {
        let id: String
        let imageData: Data
    }

    // MARK: - Private helpers

    private func documentsDirectory() -> URL {
        let fm = FileManager.default
        return fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private func photosFileURL(for login: String) -> URL {
        documentsDirectory().appendingPathComponent("photos_\(login).json")
    }

    private func hiddenBasePhotosFileURL(for login: String) -> URL {
        documentsDirectory().appendingPathComponent("hidden_base_photos_\(login).json")
    }

    // MARK: - Пользовательские фото

    func loadPhotos(for login: String) -> [StoredPhoto] {
        let url = photosFileURL(for: login)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([StoredPhoto].self, from: data)
            return decoded
        } catch {
            print("PhotoStorage: ошибка загрузки фото для \(login): \(error)")
            return []
        }
    }

    func savePhotos(_ photos: [StoredPhoto], for login: String) {
        let url = photosFileURL(for: login)
        do {
            let data = try JSONEncoder().encode(photos)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("PhotoStorage: ошибка сохранения фото для \(login): \(error)")
        }
    }

    // MARK: - Стандартные фото

    /// Загрузка множества id стандартных фоток
    func loadHiddenBasePhotoIDs(for login: String) -> Set<String> {
        let url = hiddenBasePhotosFileURL(for: login)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let ids = try JSONDecoder().decode([String].self, from: data)
            return Set(ids)
        } catch {
            print("PhotoStorage: ошибка загрузки скрытых стандартных фото для \(login): \(error)")
            return []
        }
    }

    /// Сохранение множества id стандартных фоток
    func saveHiddenBasePhotoIDs(_ ids: Set<String>, for login: String) {
        let url = hiddenBasePhotosFileURL(for: login)
        do {
            let array = Array(ids)
            let data = try JSONEncoder().encode(array)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("PhotoStorage: ошибка сохранения скрытых стандартных фото для \(login): \(error)")
        }
    }
}
