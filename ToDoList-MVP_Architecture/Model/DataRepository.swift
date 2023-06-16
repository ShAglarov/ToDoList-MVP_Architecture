//
//  DataRepository.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
// MARK: - DataRepository
/// DataRepository представляет конкретную реализацию DataRepositoryProtocol,
/// которая предоставляет средства для работы с данными заметок
final class DataRepository: DataRepositoryProtocol {
    
    // MARK: - Properties
    /// Объект для управления кэшем Core Data
    private var cache: CoreDataCacheProtocol
    
    // MARK: - Initialization
    /// Инициализация с объектом кэша Core Data
    init(cache: CoreDataCacheProtocol) {
        self.cache = cache
    }
    
    // MARK: - Fetch Notes
    /// Получение всех заметок
    func fetchNotes() async throws -> [Note] {
        return try await cache.fetchNotes()
    }
    
    // MARK: - Save Note
    /// Сохранение новой заметки
    func saveNote(note: Note) async throws {
        try await cache.saveNote(note: note)
    }
    
    // MARK: - Delete Note
    /// Удаление заметки по идентификатору
    func deleteNote(by id: UUID) async throws {
        try await cache.deleteNote(by: id)
    }
    
    // MARK: - Update Note
    /// Обновление существующей заметки
    func updateNote(_ note: Note) async throws {
        try await cache.updateNote(note)
    }
}
