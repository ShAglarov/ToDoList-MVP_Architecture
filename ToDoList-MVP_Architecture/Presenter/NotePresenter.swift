//
//  NotePresenter.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import Foundation

// MARK: - NotePresenterProtocol
/// Протокол NotePresenterProtocol определяет набор функций для управления заметками
protocol NotePresenterProtocol {
    func fetchNotes() /// Загрузка всех заметок
    func saveNote(note: Note) async /// Сохранение новой заметки
    func deleteNote(by id: UUID) async /// Удаление заметки по идентификатору
    func updateNote(_ note: Note) async /// Обновление существующей заметки
    func addNotes(notes: Note) /// Добавление новой заметки
}

// MARK: - NotePresenter
/// Класс NotePresenter реализует протокол NotePresenterProtocol и обеспечивает управление заметками
class NotePresenter: NotePresenterProtocol {
    
    private var view: NoteViewProtocol /// Ссылка на представление, которое отображает заметки
    private var repository: DataRepositoryProtocol /// Ссылка на репозиторий, откуда загружаются заметки

    // MARK: - Initialization
    init(view: NoteViewProtocol,
         repository: DataRepositoryProtocol)
    {
        self.view = view
        self.repository = repository
    }

    // MARK: - NotePresenterProtocol Implementation
    func fetchNotes() {
        view.showLoading()
        Task {
            do {
                let notes = try await repository.fetchNotes()
                DispatchQueue.main.async {
                    self.view.set(notes: notes)
                    self.view.hideLoading()
                }
            } catch {
                DispatchQueue.main.async {
                    self.view.showError(title: "Ошибка", message: error.localizedDescription)
                    self.view.hideLoading()
                }
            }
        }
    }

    func saveNote(note: Note) async {
        do {
            try await repository.saveNote(note: note)
            // Обработка результата, например, обновление UI или вывод сообщения об успешном сохранении
        } catch {
            self.view.showError(title: "Ошибка", message: error.localizedDescription)
        }
    }

    func deleteNote(by id: UUID) async {
        do {
            try await repository.deleteNote(by: id)
            // Обработка результата, например, обновление UI или вывод сообщения об успешном удалении
        } catch {
            self.view.showError(title: "Ошибка", message: error.localizedDescription)
        }
    }

    func updateNote(_ note: Note) async {
        do {
            try await repository.updateNote(note)
            // Обработка результата, например, обновление UI или вывод сообщения об успешном обновлении
        } catch {
            self.view.showError(title: "Ошибка", message: error.localizedDescription)
        }
    }
    
    func addNotes(notes: Note) {
        self.view.addNewNote()
    }
}
