//
//  CoreDataHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

///Определяем протокол для операций кэширования CoreData
protocol CoreDataCacheProtocol {
    func fetchNotes() async throws -> [Note]
    func saveNote(note: Note) async throws
    func deleteNote(by id: UUID) async throws
    func updateNote(with id: UUID, newNote: Note) async throws
}

final class CoreDataManager: CoreDataCacheProtocol {
    
    // MARK: - Properties
    /// NSPersistentContainer - это компонент CoreData, который инкапсулирует всю логику доступа к базе данных.
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    /// Инициализатор принимает NSPersistentContainer в качестве зависимости. Он используется для доступа к базе данных.
    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - Fetch Notes
    /// Эта функция выполняет запрос на выборку в базе данных и возвращает массив заметок, используется модель Note, которая создается из сущностей NoteEntity.
    func fetchNotes() async throws -> [Note] {
        let fetchRequest = NoteEntity.fetchRequest() as? NSFetchRequest<NoteEntity>
        guard let unwrappedFetchRequest = fetchRequest else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ошибка при приведении типов."])
            throw error
        }
        
        do {
            /// Выполняем запрос и преобразуем полученные сущности NoteEntity в модели Note
            let noteEntities = try persistentContainer.viewContext.fetch(unwrappedFetchRequest)
            // Добавляем сортировку
            return noteEntities.map { Note(from: $0) }.sorted(by: { $0.dueDate > $1.dueDate })
        } catch {
            throw error
        }
    }
    
    // MARK: - Save Note
    /// Сохраняем заметку в базе данных.
    func saveNote(note: Note) throws {
        let context = persistentContainer.viewContext
        // Создаем сущность NoteEntity и заполняем ее данными из модели Note
        let entity = NoteEntity(context: context)
        entity.id = note.id
        entity.title = note.title
        entity.isComplete = note.isComplete
        entity.dueDate = note.dueDate
        entity.note = note.note
        // Сохраняем контекст, чтобы записать данные в базу данных
        try context.save()
    }
    
    // MARK: - Delete Note
    /// Удаляем заметку из базы данных.
    func deleteNote(by id: UUID) async throws {
        let context = persistentContainer.viewContext
        // Создаем запрос на удаление сущности NoteEntity с определенным идентификатором
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            // Выполняем запрос, удаляем сущность и сохраняем контекст
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let noteToDelete = results.first {
                context.delete(noteToDelete)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Update Note
    /// обновляем заметки в базе данных CoreData
    func updateNote(with id: UUID, newNote: Note) async throws {
        let context = persistentContainer.viewContext
        // Создаем запрос на получение сущности NoteEntity с определенным идентификатором
        let fetchRequest = NoteEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            // Выполняем запрос, обновляем сущность и сохраняем контекст
            let noteEntities = try context.fetch(fetchRequest) as! [NoteEntity]
            print("Получено \(noteEntities.count) сущности") // Проверяем количество найденных сущностей
            
            guard let entity = noteEntities.first else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти заметку с указанным ID."])
            }
            
            print("Старый объект: \(entity)") // Печатаем старую сущность
            entity.title = newNote.title
            entity.isComplete = newNote.isComplete
            entity.dueDate = newNote.dueDate
            entity.note = newNote.note
            print("Обновленный объект: \(entity)") // Печатаем обновленную сущность
            
            try context.save()
            print("Объект сохранен") // Печатаем сообщение после успешного сохранения
        } catch {
            print("Не удалось обновить заметку: \(error)") // Печатаем ошибку, если она произошла
            throw error
        }
    }
}
