//
//  Note.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation
import CoreData

struct Note: CoreDataManagerProtocol {
    
    typealias Entity = NoteEntity
    
    let id: UUID
    let title: String
    var isComplete: Bool
    let dueDate: Date
    let note: String
    
    // Initialize Note from NoteEntity
    init(from entity: NoteEntity) {
        id = entity.id!
        title = entity.title!
        isComplete = entity.isComplete
        dueDate = entity.dueDate!
        note = entity.note!
    }
    
    // Direct initialization
    init(id: UUID = UUID(), title: String, isComplete: Bool = false, dueDate: Date = Date(), note: String) {
        self.id = id
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.note = note
    }
    // Convert Note to NoteEntity
    func toEntity(context: NSManagedObjectContext) -> NoteEntity {
        let entity = NoteEntity(context: context)
        updateEntity(entity)
        return entity
    }
    func updateEntity(_ entity: NoteEntity) {
        entity.id = id
        entity.title = title
        entity.isComplete = isComplete
        entity.dueDate = dueDate
        entity.note = note
    }
    
    static func newInstance(id: UUID = UUID(), title: String, isComplete: Bool = false, dueDate: Date = Date(), note: String) -> Note {
        return Note(id: id, title: title, isComplete: isComplete, dueDate: dueDate, note: note)
    }
}
