//
//  ExtensionAddingNotes.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 19.06.2023.
//

import Foundation
import UIKit

extension NoteViewController {
    
    // MARK: - NoteViewProtocol Methods
    
    /// Метод для создания новой заметки при нажатии на кнопку "Создать"
    func createButtonTapped() {
        let alertAddNoteController = UIAlertController(title: "Добавить новую заметку", message: "", preferredStyle: .alert)
        
        alertAddNoteController.addTextField { textField in
            textField.placeholder = "Введите заголовок заметки"
        }
        alertAddNoteController.addTextField { textField in
            textField.placeholder = "Введите текст заметки"
        }
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let titleField = alertAddNoteController.textFields?[0]
            let noteField = alertAddNoteController.textFields?[1]
            
            if let title = titleField?.text, !title.isEmpty,
               let note = noteField?.text, !note.isEmpty {
                let newNote = Note.newInstance(title: title, note: note)
                self.presenter.addNewNote(newNote)
            }
            
//            if let title = titleField?.text, !title.isEmpty,
//               let note = noteField?.text, !note.isEmpty {
//                let newNote = Note(from: <#T##NoteEntity#>)
//
//                self.presenter.addNewNote(newNote)
//            } else {
//                self.showError(title: "Ввведите все поля", message: "Для добавления заметки, необходимо заполнить все поля")
//            }
        }
        
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        alertAddNoteController.addAction(addAction)
        alertAddNoteController.addAction(cancelAction)
        self.present(alertAddNoteController, animated: true)
    }
    
    /// Вставляет новую заметку в массив и обновляет таблицу
    func insertNoteInArrayAndReload(at indexPath: IndexPath, with note: Note) {
        tableView.beginUpdates() // начинаем обновление
        notes.insert(note, at: indexPath.row) // Добавляем новую заметку в начало массива
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates() // заканчиваем обновление
    }
    
    // MARK: - Other Functions
    
    /// Функция, выполняемая при нажатии на кнопку добавления заметки
    @objc func actionBarButtonAdd() {
        createButtonTapped()
    }
}
