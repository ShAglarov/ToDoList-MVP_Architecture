//
//  FileHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
// MARK: - FileHandlerProtocol
/// Протокол определяет контракт для классов, которые предоставляют
/// средства для чтения и записи данных в файл
protocol FileHandlerProtocol {
    func loadDataContent(completion: @escaping (Result<Data, Error>) -> Void)  /// Читает данные из файла
    func writeData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) /// Записывает данные в файл
}

// MARK: - FileHandler
/// FileHandler представляет конкретную реализацию FileHandlerProtocol,
/// которая предоставляет средства для чтения и записи данных в файл
class FileHandler: FileHandlerProtocol {
    
    // MARK: - Properties
    /// URL файла для чтения/записи данных
    private var url: URL

    // MARK: - Initialization
    /// Инициализация с созданием файла, если он еще не существует
    init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url = documentsDirectory.appendingPathComponent("todo").appendingPathExtension("plist")

        // проверяем есть ли файл по url ссылке
        if !FileManager.default.fileExists(atPath: url.path) {
            // если файл отсутствует создаем новый файл
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
    }

    // MARK: - Load Data
    /// Чтение данных из файла
    func loadDataContent(completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data(contentsOf: self.url)
                completion(.success(data))
            } catch {
                print("При чтении данных произошла ошибка: \(error.localizedDescription)")
                // Дополнительные действия здесь...
                completion(.failure(error))
            }
        }
    }

    // MARK: - Write Data
    /// Запись данных в файл
    func writeData(_ data: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: self.url)
                completion(.success(()))
            } catch {
                print("При записи данных произошла ошибка: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
