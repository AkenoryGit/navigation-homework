//
//  NetworkService.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import Foundation

struct NetworkService {
    static func request<T: Decodable>(url: URL?, completion: @escaping ([T]) -> Void) {
        guard let url = url else {
            print("Невалидный URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
            }

            guard let data = data else {
                print("Нет данных")
                return
            }

            print("Raw JSON: \(String(data: data, encoding: .utf8) ?? "не удалось преобразовать")")

            do {
                if url.absoluteString.contains("todos") {
                    let decoded = try JSONDecoder().decode([T].self, from: data)
                    completion(decoded)
                } else {
                    let decoded = try JSONDecoder().decode(GenericResponse<T>.self, from: data)
                    completion(decoded.results)
                }
            } catch {
                print("Ошибка при декодировании: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
}

struct GenericResponse<T: Decodable>: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}


enum AppConfiguration: String, CaseIterable {
    case people = "https://swapi.py4e.com/api/people"
    case starships = "https://swapi.py4e.com/api/starships"
    case planets = "https://swapi.py4e.com/api/planets"
    case todos = "https://jsonplaceholder.typicode.com/todos"

    var url: URL? {
        URL(string: self.rawValue)
    }
}
