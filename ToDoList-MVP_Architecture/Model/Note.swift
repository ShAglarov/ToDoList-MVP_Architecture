//
//  Note.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation

// MARK: - Note
/// Структура Note представляет модель заметки и реализует протоколы Codable, Identifiable и Equatable.
struct Note: Codable, Identifiable, Equatable {
    
    // MARK: - Properties
    /// Уникальный идентификатор заметки
    var id = UUID()
    
    /// Заголовок заметки
    var title: String
    
    /// Статус выполнения заметки
    var isComplete: Bool
    
    /// Срок исполнения заметки
    var dueDate: Date

    /// Дополнительные заметки
    var note: String?
    
    // MARK: - Initialization
    /// Инициализатор для создания новой заметки
    init(id: UUID = UUID(),
         title: String,
         isComplete: Bool,
         dueDate: Date,
         note: String? = nil)
    {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.note = note
    }
    
    // MARK: - Equatable
    /// Функция для сравнения двух заметок на равенство
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Note Extension
/// Расширение Note для инициализации из сущности NoteEntity
extension Note {
    init(from entity: NoteEntity) {
        /// Инициализирует заметку из сущности NoteEntity
        self.id = entity.id ?? UUID()
        self.title = entity.title ?? ""
        self.isComplete = entity.isComplete
        self.dueDate = entity.dueDate ?? Date()
        self.note = entity.note ?? ""
    }
}
