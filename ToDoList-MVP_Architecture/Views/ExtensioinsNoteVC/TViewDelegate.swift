//
//  ExtensionDelegate.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 19.06.2023.
//

import Foundation
import UIKit

// MARK: - Реализация методов UITableViewDelegate
extension NoteViewController: UITableViewDelegate {
    
    /// Настраивает конфигурацию для смахивания ячейки влево
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Действие удаления
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let selectedNote = self.notes[indexPath.row]
            self.presenter.deleteNote(by: selectedNote.id)
            self.notes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // Действие редактирования
        let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let selectedNote = self.notes[indexPath.row]
            self.showEditAlert(for: selectedNote, at: indexPath)
            completionHandler(true)
        }
        
        // Настраиваем цвет действий
        editAction.backgroundColor = .blue
        deleteAction.backgroundColor = .red
        
        // Возвращаем конфигурацию действий
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    /// Обрабатывает нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.beginUpdates()
        
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            // Если нажатая ячейка уже была выбрана, то скрываем детали
            self.selectedIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            // Если выбрана другая ячейка, то скрываем детали предыдущей и показываем детали новой
            let previouslySelectedIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [previouslySelectedIndexPath, selectedIndexPath].compactMap { $0 }, with: .automatic)
        }
        
        tableView.endUpdates()
    }
    
    /// Показывает диалоговое окно редактирования заметки
    func showEditAlert(for note: Note, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Редактировать заметку", message: "Введите новые данные", preferredStyle: .alert)
        
        // Добавление полей для ввода нового названия и содержимого заметки
        alertController.addTextField { (textField) in
            textField.text = note.title
        }
        
        alertController.addTextField { (textField) in
            textField.text = note.note
        }
        
        // Действие сохранения изменений
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let newTitle = alertController.textFields?[0].text ?? ""
            let newNotes = alertController.textFields?[1].text ?? ""
            let newNote = Note(id: note.id, title: newTitle, isComplete: note.isComplete, dueDate: note.dueDate, note: newNotes)
            
            self.presenter.updateNote(withId: newNote.id, newNote: newNote)
        }
        
        // Действие отмены редактирования
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        // Добавление действий в диалоговое окно
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        // Показ диалогового окна
        self.present(alertController, animated: true, completion: nil)
    }
}
