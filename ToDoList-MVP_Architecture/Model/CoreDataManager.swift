//
//  CoreDataHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

// MARK: - CoreDataCacheProtocol
/// Протокол, определяющий интерфейс операций кэширования CoreData
protocol CoreDataCacheProtocol {
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void)
    func saveNote(note: Note, completion: @escaping (Error?) -> Void)
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void)
    func updateNote(with id: UUID, newNote: Note, completion: @escaping (Result<NoteEntity, Error>) -> Void)
}

// MARK: - CoreDataManager
/// Управление CoreData операциями, такими как сохранение, удаление, обновление и извлечение заметок.
final class CoreDataManager: CoreDataCacheProtocol {
    
    // MARK: - Properties
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - Fetch Notes
    /// Выполняет запрос на выборку в базе данных и возвращает массив заметок.
    func fetchNotes(completion: @escaping (Result<[Note], Error>) -> Void) {
        let fetchRequest = NoteEntity.fetchRequest() as? NSFetchRequest<NoteEntity>
        guard let unwrappedFetchRequest = fetchRequest else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при приведении типов."])
            completion(.failure(error))
            return
        }
        
        persistentContainer.viewContext.perform {
            do {
                let noteEntities = try self.persistentContainer.viewContext.fetch(unwrappedFetchRequest)
                let notes = noteEntities.map { Note(from: $0) }.sorted(by: { $0.dueDate > $1.dueDate })
                completion(.success(notes))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Save Note
    /// Сохраняет заметку в базе данных.
    func saveNote(note: Note, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            let entity = NoteEntity(context: context)
            entity.id = note.id
            entity.title = note.title
            entity.isComplete = note.isComplete
            entity.dueDate = note.dueDate
            entity.note = note.note
            
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    // MARK: - Delete Note
    /// Удаляет заметку из базы данных.
    func deleteNote(by id: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        context.perform {
            do {
                if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let noteToDelete = results.first {
                    context.delete(noteToDelete)
                    try context.save()
                    completion(nil)
                }
            } catch {
                completion(error)
            }
        }
    }
    
    // MARK: - Update Note
    /// Обновляет заметку в базе данных.
    func updateNote(with id: UUID, newNote: Note, completion: @escaping (Result<NoteEntity, Error>) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NoteEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        context.perform {
            do {
                let noteEntities = try context.fetch(fetchRequest) as! [NoteEntity]
                guard let entity = noteEntities.first else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти заметку с указанным ID."])
                    completion(.failure(error))
                    return
                }
                
                entity.title = newNote.title
                entity.isComplete = newNote.isComplete
                entity.dueDate = newNote.dueDate
                entity.note = newNote.note
                
                try context.save()
                completion(.success(entity))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
}
