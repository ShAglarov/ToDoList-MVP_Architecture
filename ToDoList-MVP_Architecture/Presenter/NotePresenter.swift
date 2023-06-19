//
//  NotePresenter.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation

// MARK: - NotePresenterProtocol

/// NotePresenterProtocol определяет набор функций для управления заметками
protocol NotePresenterProtocol {
    /// Извлекает заметки из базы данных
    func fetchNotes() async throws
    
    /// Удаляет заметку по ID
    func deleteNote(by id: UUID) async throws
    
    /// Обновляет заметку с данным ID новыми данными
    func updateNote(withId id: UUID, newNote: Note) async throws
    
    /// Добавляет новую заметку
    func addNewNote(_ note: Note) async throws
    
    /// Возвращает имя изображения в зависимости от того, выполнена заметка или нет
    func getImageName(for isComplete: Bool) -> String
}

// MARK: - NotePresenter

/// NotePresenter управляет отображением заметок и обрабатывает пользовательский ввод
class NotePresenter: NotePresenterProtocol {
    
    private var view: NoteViewProtocol
    private var repository: DataRepositoryProtocol
    private var tasks: Set<Task<Void, Never>> = []
    private var expandedIndexPath: IndexPath?
    
    init(view: NoteViewProtocol,
         repository: DataRepositoryProtocol)
    {
        self.view = view
        self.repository = repository
    }
    
    // MARK: - Fetch Notes
    
    /// Извлекает заметки из базы данных и обновляет представление
    func fetchNotes() async throws {
        view.showLoading()
        let task = Task {
            do {
                let notes = try await repository.fetchNotes()
                await MainActor.run {
                    self.view.set(notes: notes)
                    self.view.hideLoading()
                }
            } catch {
                await MainActor.run {
                    self.view.showError(title: "Ошибка", message: error.localizedDescription)
                    self.view.hideLoading()
                }
            }
        }
        tasks.insert(task)
    }
    
    // MARK: - Delete Note
    
    /// Удаляет заметку по ID
    func deleteNote(by id: UUID) async throws {
        try await repository.deleteNote(by: id)
    }
    
    // MARK: - Update Note
    
    /// Обновляет заметку с данным ID новыми данными
    func updateNote(withId id: UUID, newNote: Note) async throws {
        try await repository.updateNote(by: id, newNote: newNote)
        
        if let index = view.notes.enumerated().first(where: { $0.element.id == id })?.offset {
            let indexPath = IndexPath(row: index, section: 0)
            
            let task = Task {
                await MainActor.run {
                    self.view.updateNoteInArray(at: indexPath, with: newNote)
                    self.view.didReloadRows(at: indexPath)
                }
            }
            tasks.insert(task)
        }
    }
    
    // MARK: - Image for Note
    
    /// Возвращает имя изображения в зависимости от того, выполнена заметка или нет
    func getImageName(for isComplete: Bool) -> String {
        return isComplete ? "checkmark.circle.fill" : "circle"
    }
    
    // MARK: - Add Note
    
    /// Добавляет новую заметку
    func addNewNote(_ note: Note) async throws {
        let indexPath = IndexPath(row: 0, section: 0)
        
        try await repository.saveNote(note: note)
        
        let task = Task {
            await MainActor.run {
                self.view.insertNoteInArrayAndReload(at: indexPath, with: note)
            }
        }
        tasks.insert(task)
    }
}
