//
//  NetworkService.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import Foundation

struct NetworkService {
    static func request<T: Decodable>(for configuration: AppConfiguration, completion: @escaping ([T]) -> Void) {
        let urlString: String

        switch configuration {
        case .people:
            urlString = "https://swapi.py4e.com/api/people"
        case .starships:
            urlString = "https://swapi.py4e.com/api/starships"
        case .planets:
            urlString = "https://swapi.py4e.com/api/planets"
        }

        guard let url = URL(string: urlString) else {
            print("Невалидный URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Сервер вернул ошибку")
                return
            }

            guard let data = data else {
                print("Нет данных")
                return
            }
            
            print("DATA:")
            print(String(data: data, encoding: .utf8) ?? "Не удалось декодировать данные")

            print("HEADERS:")
            print(httpResponse.allHeaderFields)

            print("STATUS CODE:")
            print(httpResponse.statusCode)

            do {
                let decodedResponse = try JSONDecoder().decode(GenericResponse<T>.self, from: data)
                completion(decodedResponse.results)
            } catch {
                print("Ошибка при декодировании: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Ключ не найден: \(key), контекст: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Несоответствие типа: \(type), контекст: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Значение не найдено: \(type), контекст: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Данные повреждены: \(context.debugDescription)")
                    @unknown default:
                        print("Неизвестная ошибка декодирования")
                    }
                }
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


enum AppConfiguration {
    case people
    case starships
    case planets
}
