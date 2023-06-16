//
//  CoreDataHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

// MARK: - CoreDataCacheProtocol
/// Протокол для управления заметками, используя Core Data
protocol CoreDataCacheProtocol {
    func fetchNotes() async throws -> [Note] /// Получает все заметки из Core Data
    func saveNote(note: Note) async throws   /// Сохраняет новую заметку в Core Data
    func deleteNote(by id: UUID) async throws /// Удаляет заметку по идентификатору из Core Data
    func updateNote(_ note: Note) async throws /// Обновляет существующую заметку в Core Data
}

// MARK: - CoreDataHandler
/// Класс для управления заметками, используя Core Data
final class CoreDataHandler: CoreDataCacheProtocol {
    
    // MARK: - Properties
    /// Объект для управления Core Data
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    /// Инициализация с контейнером Core Data
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - Fetch Notes
    /// Получение всех заметок из Core Data
    func fetchNotes() async throws -> [Note] {
        let fetchRequest = NoteEntity.fetchRequest() as? NSFetchRequest<NoteEntity>
        guard let unwrappedFetchRequest = fetchRequest else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при приведении типов."])
        }
        
        let noteEntities = try persistentContainer.viewContext.fetch(unwrappedFetchRequest)
        return noteEntities.map { Note(from: $0) }
    }
    
    // MARK: - Save Note
    /// Сохранение новой заметки в Core Data
    func saveNote(note: Note) async throws {
        let context = persistentContainer.viewContext
        let entity = NoteEntity(context: context)
        entity.from(note: note)
        
        try context.save()
    }
    
    // MARK: - Delete Note
    /// Удаление заметки по идентификатору из Core Data
    func deleteNote(by id: UUID) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
    }
    
    // MARK: - Update Note
    /// Обновление существующей заметки в Core Data
    func updateNote(_ note: Note) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        let noteEntities = try context.fetch(fetchRequest) as! [NoteEntity]
        guard let noteEntity = noteEntities.first else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти заметку с указанным ID."])
        }
        
        noteEntity.from(note: note)
        try context.save()
    }
}
