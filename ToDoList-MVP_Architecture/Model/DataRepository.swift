//
//  DataRepository.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
// Фреймворк Foundation предоставляет базовые типы данных, коллекции и другие примитивы, используемые в Swift-приложениях.

import Foundation
import CoreData

// MARK: - DataRepositoryProtocol
/// Протокол, определяющий интерфейс операций работы с данными
protocol DataRepositoryProtocol {
    /// Извлекает все заметки
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void)
    
    /// Сохраняет новую заметку
    func save(note: Note, completion: @escaping (Error?) -> Void)
    
    /// Удаляет заметку по ID
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void)
    
    /// Обновляет существующую заметку по ID
    func update(id: UUID, with newNote: Note, completion: @escaping (Error?) -> Void)
}

// MARK: - DataRepository
/// Класс, ответственный за управление операциями работы с данными
final class DataRepository: DataRepositoryProtocol {
    /// Менеджер для взаимодействия с базой данных
    private var manager: CoreDataManager<Note>

    /// Инициализатор принимает экземпляр `CoreDataManager`
    init(manager: CoreDataManager<Note>) {
        self.manager = manager
    }

    /// Извлекает все заметки из базы данных
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void) {
        manager.fetch(completion: completion)
    }

    /// Сохраняет новую заметку в базу данных
    func save(note: Note, completion: @escaping (Error?) -> Void) {
        manager.save(model: note, completion: completion)
    }

    /// Удаляет заметку по ID из базы данных
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void) {
        manager.delete(by: id, completion: completion)
    }

    /// Обновляет существующую заметку по ID в базе данных
    func update(id: UUID, with newNote: Note, completion: @escaping (Error?) -> Void) {
        manager.update(id: id, with: newNote, completion: completion)
    }
}
