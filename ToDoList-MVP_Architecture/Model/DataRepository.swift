//
//  DataRepository.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
// Фреймворк Foundation предоставляет базовые типы данных, коллекции и другие примитивы, используемые в Swift-приложениях.

import Foundation

// MARK: - DataRepositoryProtocol
// Создаем протокол для нашего репозитория данных, чтобы упростить будущее тестирование и поддержку.
protocol DataRepositoryProtocol {
    func fetchNotes() async throws -> [Note]
    func saveNote(note: Note) async throws
    func deleteNote(by id: UUID) async throws
    func updateNote(by id: UUID, newNote: Note) async throws
}
// MARK: - DataRepository
// Наш репозиторий данных. Этот класс используется для взаимодействия с нашей базой данных (или любым другим источником данных).
final class DataRepository: DataRepositoryProtocol {
    
    // MARK: - Properties
    /// Ссылка на наш кэш CoreData, который мы используем для сохранения и извлечения данных.
    private var cache: CoreDataCacheProtocol
    
    // MARK: - Initialization
    // Инициализатор. Принимает кэш в качестве аргумента, чтобы обеспечить гибкость нашего репозитория данных.
    /// Это также облегчает тестирование, поскольку мы можем передать фиктивный кэш.
    init(cache: CoreDataCacheProtocol) {
        self.cache = cache
    }
    
    // MARK: - DataRepositoryProtocol Methods
    /// Извлекаем заметки из нашего кэша.
    func fetchNotes() async throws -> [Note] {
        return try await cache.fetchNotes()
    }
    
    /// Сохраняем заметку в нашем кэше.
    func saveNote(note: Note) async throws {
        try await cache.saveNote(note: note)
    }
    
    /// Удаляем заметку из нашего кэша.
    func deleteNote(by id: UUID) async throws {
        try await cache.deleteNote(by: id)
    }
    
    /// Обновляем заметку в нашем кэше.
    func updateNote(by id: UUID, newNote: Note) async throws {
        try await cache.updateNote(with: id, newNote: newNote)
    }
}
