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
    func fetchNotes()
    
    /// Удаляет заметку по ID
    func deleteNote(by id: UUID)
    
    /// Обновляет заметку с данным ID новыми данными
    func updateNote(withId id: UUID, newNote: Note)
    
    /// Добавляет новую заметку
    func addNewNote(_ note: Note)
    
    /// Возвращает имя изображения в зависимости от того, выполнена заметка или нет
    func getImageName(for isComplete: Bool) -> String
}

// MARK: - NotePresenter

class NotePresenter: NotePresenterProtocol {
    
    private var view: NoteViewProtocol
    private var repository: DataRepositoryProtocol
    private var tasks: Set<Task<Void, Never>> = []
    private var expandedIndexPath: IndexPath?
    
    /// Инициализирует презентер, связывает его с представлением и репозиторием.
    init(view: NoteViewProtocol,
         repository: DataRepositoryProtocol)
    {
        self.view = view
        self.repository = repository
    }
    
    // MARK: - Fetch Notes
    
    /// Запрашивает заметки из репозитория и передает их представлению.
    func fetchNotes() {
        view.showLoading()
        repository.fetchNotes { result in
            switch result {
            case .success(let notes):
                DispatchQueue.main.async {
                    self.view.set(notes: notes)
                    self.view.hideLoading()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view.showError(title: "Ошибка", message: error.localizedDescription)
                    self.view.hideLoading()
                }
            }
        }
    }
    
    // MARK: - Delete Note
    
    /// Удаляет заметку с заданным идентификатором.
    func deleteNote(by id: UUID) {
        repository.deleteNote(by: id) { error in
            if let error = error {
                self.view.showError(title: "Ошибка, при удалении ячейки", message: error.localizedDescription)
            } else {
                print("ячейка успешно удалена")
            }
        }
    }
    
    // MARK: - Update Note
    
    /// Обновляет заметку с заданным идентификатором новой заметкой.
    func updateNote(withId id: UUID, newNote: Note) {
        repository.update(id: id, with: newNote) { error in
            if let error = error {
                self.view.showError(title: "Ошибка при обновлении ячейки", message: error.localizedDescription)
            } else {
                if let index = self.view.notes.enumerated().first(where: { $0.element.id == id })?.offset {
                    let indexPath = IndexPath(row: index, section: 0)
                    DispatchQueue.main.async {
                        self.view.updateNoteInArray(at: indexPath, with: newNote)
                        self.view.didReloadRows(at: indexPath)
                    }
                }
            }
        }
    }
    
    // MARK: - Image Name
    
    /// Возвращает имя изображения в зависимости от статуса выполнения заметки.
    func getImageName(for isComplete: Bool) -> String {
        return isComplete ? "checkmark.circle.fill" : "circle"
    }
    
    // MARK: - Add New Note
    
    /// Добавляет новую заметку и обновляет представление.
    func addNewNote(_ note: Note) {
        let indexPath = IndexPath(row: 0, section: 0)
        
        repository.save(note: note) { error in
            if let error = error {
                self.view.showError(title: "Ошибка при добавлении ячейки", message: error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.view.insertNoteInArrayAndReload(at: indexPath, with: note)
                }
            }
        }
    }
}
