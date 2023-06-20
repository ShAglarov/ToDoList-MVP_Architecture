//
//  ExtensionDataSource.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 19.06.2023.
//

import UIKit

// MARK: - Реализация UITableViewDataSource
extension NoteViewController: UITableViewDataSource {

    /// Определяет количество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    /// Заполняет каждую ячейку таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Создание элементов ячейки
        let iconButton = UIButton(type: .custom)
        let titleLabel = UILabel()
        let detailLabel = UILabel()
        let separatorLine = UIView()
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // Установка констрейнтов для элементов ячейки
        setupCellConstraints(iconButton: iconButton,
                             titleLabel: titleLabel,
                             detailLabel: detailLabel,
                             separatorLine: separatorLine,
                             cell: cell)
        
        // Получение заметки для текущей ячейки
        let note = notes[indexPath.row]
        let imageName = presenter.getImageName(for:note.isComplete)
        
        // Настройка элементов ячейки
        iconButton.setImage(UIImage(systemName: imageName), for: .normal)
        titleLabel.text = note.title
        detailLabel.text = note.note
        
        // Добавление действия на кнопку
        iconButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        // Установка тега для кнопки, равного индексу строки, чтобы можно было идентифицировать нажатую кнопку
        iconButton.tag = indexPath.row
        
        // Отображение деталей для выбранной ячейки
        if indexPath == selectedIndexPath {
            detailLabel.snp.makeConstraints { make in
                make.top.equalTo(separatorLine.snp.bottom).offset(10)
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalTo(titleLabel.snp.trailing)
                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-50)
            }
            detailLabel.isHidden = false
        } else {
            detailLabel.isHidden = true
        }
        
        return cell
    }
    
    /// Действие при нажатии на кнопку ячейки
    @objc func buttonAction(sender: UIButton) {
        // Найти ячейку, в которой находится кнопка
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else { return }
        
        var note = notes[indexPath.row]
        note.isComplete.toggle()
        
        Task {
            do {
                try await self.presenter.updateNote(withId: note.id, newNote: note)
                await MainActor.run {
                    tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .automatic)
                }
            } catch {
                print("Ошибка выборки")
            }
        }
    }
}
