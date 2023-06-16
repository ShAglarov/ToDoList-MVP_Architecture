//
//  NoteEntity.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

// MARK: - NoteEntity
/// Класс NoteEntity представляет собой сущность CoreData для хранения заметок.
@objc(NoteEntity)
public class NoteEntity: NSManagedObject {
    
    // MARK: - Properties
    /// Уникальный идентификатор заметки
    @NSManaged public var id: UUID?
    
    /// Заголовок заметки
    @NSManaged public var title: String?
    
    /// Статус выполнения заметки
    @NSManaged public var isComplete: Bool
    
    /// Срок исполнения заметки
    @NSManaged public var dueDate: Date?
    
    /// Дополнительные заметки
    @NSManaged public var notes: String?
    
    // MARK: - Initialization
    /// Инициализатор для создания сущности NoteEntity из заметки и контекста
    convenience init(from note: Note, context: NSManagedObjectContext) {
        /// Инициализирует сущность NoteEntity из заметки и контекста
        self.init(context: context)
        
        self.id = note.id
        self.title = note.title
        self.isComplete = note.isComplete
        self.dueDate = note.dueDate
        self.notes = note.notes
    }
}
