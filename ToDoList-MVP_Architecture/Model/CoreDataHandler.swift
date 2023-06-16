//
//  CoreDataHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

protocol CoreDataCacheProtocol {
    func fetchNotes() async throws -> [Note]
    func saveNote(note: Note) async throws
    func deleteNote(by id: UUID) async throws
    func updateNote(_ note: Note) async throws
}

final class CoreDataHandler: CoreDataCacheProtocol {
    
    // MARK: - Properties
    // NSPersistentContainer - это компонент CoreData, который инкапсулирует всю логику доступа к базе данных.
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    // Инициализатор принимает NSPersistentContainer в качестве зависимости. Он используется для доступа к базе данных.
    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - Fetch Notes
    // Эта функция выполняет запрос на выборку в базе данных и возвращает массив заметок.
    // Используется модель Note, которая создается из сущностей NoteEntity.
    func fetchNotes() async throws -> [Note] {
        let fetchRequest = NoteEntity.fetchRequest() as? NSFetchRequest<NoteEntity>
        guard let unwrappedFetchRequest = fetchRequest else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при приведении типов."])
            throw error
        }
        
        do {
            let noteEntities = try persistentContainer.viewContext.fetch(unwrappedFetchRequest)
            return noteEntities.map { Note(from: $0) }
        } catch {
            throw error
        }
    }
    
    // MARK: - Save Note
    // Эта функция сохраняет заметку в базе данных. Она создает сущность NoteEntity и заполняет ее данными из заметки.
    // После этого сохраняет контекст, фиксируя изменения в базе данных.
    func saveNote(note: Note) throws {
        let context = persistentContainer.viewContext
        let entity = NoteEntity(context: context)
        entity.id = note.id
        entity.title = note.title
        entity.isComplete = note.isComplete
        entity.dueDate = note.dueDate
        entity.notes = note.notes
        
        try context.save()
    }
    
    // MARK: - Delete Note
    // Эта функция удаляет заметку из базы данных. Она создает запрос на удаление, который удаляет все сущности, соответствующие предикату.
    // Затем выполняет запрос и сохраняет контекст.
    func deleteNote(by id: UUID) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest = NoteEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            throw error
        }
    }
    
    // MARK: - Update Note
    // Эта функция обновляет заметку в базе данных. Она создает запрос на выборку, который возвращает все сущности, соответствующие предикату.
    // Затем обновляет сущность и сохраняет контекст.
    func updateNote(_ note: Note) async throws {
        let context = persistentContainer.viewContext
        let fetchRequest = NoteEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
        
        do {
            let noteEntities = try context.fetch(fetchRequest) as! [NoteEntity]
            guard let noteEntity = noteEntities.first else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти заметку с указанным ID."])
            }
            noteEntity.title = note.title
            noteEntity.isComplete = note.isComplete
            noteEntity.dueDate = note.dueDate
            noteEntity.notes = note.notes
            
            try context.save()
        } catch {
            throw error
        }
    }
}
