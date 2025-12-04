//
//  MusicStorage.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

/// Хранилище списка всех треков и избранного для конкретных пользователей
final class MusicStorage {

    static let shared = MusicStorage()

    private init() {}

    // MARK: - Все доступные треки в приложении

    /// Общий каталог треков (лежат в бандле в папке Music/Tracks)
    let allTracks: [MusicTrack] = [
        MusicTrack(id: "babylki",
                   title: "Бабульки",
                   fileName: "Бабульки"),
        MusicTrack(id: "valentin_strykalo",
                   title: "Валентин Стрыкало",
                   fileName: "Валентин Стрыкало"),
        MusicTrack(id: "kachok",
                   title: "Качок",
                   fileName: "Качок"),
        MusicTrack(id: "krovostok_cvety_v_vaze",
                   title: "Кровосток – Цветы в вазе",
                   fileName: "Кровосток - Цветы в вазе"),

        MusicTrack(id: "ambel_endless_heat",
                   title: "Ambel – Endless Heat",
                   fileName: "Ambel - Endless Heat (zaycev.net)"),
        MusicTrack(id: "arthur_just_need_to_say",
                   title: "Arthur Freedom – Just Need To Say",
                   fileName: "Arthur Freedom - Just Need To Say (zaycev.net)"),
        MusicTrack(id: "arthur_run_my_body",
                   title: "Arthur Freedom, Dinamixx – Run My Body",
                   fileName: "Arthur Freedom, Dinamixx - Run My Body (zaycev.net)"),
        MusicTrack(id: "dinamixx_faces",
                   title: "Dinamixx – Faces",
                   fileName: "Dinamixx - Faces (zaycev.net)"),
        MusicTrack(id: "inward_midnight_pulse",
                   title: "Inward Universe – Midnight Pulse",
                   fileName: "Inward Universe - Midnight Pulse (zaycev.net)"),
        MusicTrack(id: "jey_lilan_vibes",
                   title: "JEY LILAN – Vibes",
                   fileName: "JEY LILAN - Vibes (zaycev.net)"),
        MusicTrack(id: "queen_show_must_go_on",
                   title: "Queen – The Show Must Go On",
                   fileName: "Queen - The Show Must Go On"),
        MusicTrack(id: "fire_show",
                   title: "STVRLXGHT, SXCXND ADVXNT – Fire Show",
                   fileName: "STVRLXGHT, SXCXND ADVXNT - Fire Show (zaycev.net)"),
        MusicTrack(id: "sxcrets_close_u_eyes",
                   title: "Sxcrets – Close u eyes",
                   fileName: "Sxcrets - Close u eyes (zaycev.net)"),
        MusicTrack(id: "vo9an_upper",
                   title: "vo9an – upper",
                   fileName: "vo9an - upper (zaycev.net)")
    ]

    // MARK: - Вспомогательное

    /// Найти трек по id
    func track(withId id: String) -> MusicTrack? {
        allTracks.first { $0.id == id }
    }

    // MARK: - Избранное (UserDefaults, привязка к логину)

    private func favoritesKey(for login: String) -> String {
        "favoriteTracks_\(login)"
    }

    /// Множество id треков, добавленных в избранное
    private func loadFavoriteIDs(for login: String) -> Set<String> {
        let key = favoritesKey(for: login)
        let array = UserDefaults.standard.stringArray(forKey: key) ?? []
        return Set(array)
    }

    private func saveFavoriteIDs(_ ids: Set<String>, for login: String) {
        let key = favoritesKey(for: login)
        UserDefaults.standard.set(Array(ids), forKey: key)
    }

    // MARK: - Публичный API

    func favoriteTracks(for login: String) -> [MusicTrack] {
        let ids = loadFavoriteIDs(for: login)
        return allTracks.filter { ids.contains($0.id) }
    }

    func isFavorite(_ track: MusicTrack, for login: String) -> Bool {
        loadFavoriteIDs(for: login).contains(track.id)
    }

    func toggleFavorite(_ track: MusicTrack, for login: String) {
        var ids = loadFavoriteIDs(for: login)
        if ids.contains(track.id) {
            ids.remove(track.id)
        } else {
            ids.insert(track.id)
        }
        saveFavoriteIDs(ids, for: login)
    }
}
