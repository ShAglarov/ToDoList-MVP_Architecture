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
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void)
    func saveNote(note: Note, completion: @escaping (Error?) -> Void)
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void)
    func updateNote(by id: UUID, newNote: Note, completion: @escaping (Result<NoteEntity, Error>) -> Void)
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
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void) {
        cache.fetchNotes(completion: completion)
    }
    
    /// Сохраняем заметку в нашем кэше.
    func saveNote(note: Note, completion: @escaping (Error?) -> Void) {
        cache.saveNote(note: note, completion: completion)
    }
    
    /// Удаляем заметку из нашего кэша.
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void) {
        cache.deleteNote(by: id, completion: completion)
    }
    
    /// Обновляем заметку в нашем кэше.
    func updateNote(by id: UUID, newNote: Note, completion: @escaping (Result<NoteEntity, Error>) -> Void) {
        cache.updateNote(with: id, newNote: newNote, completion: completion)
    }
}
