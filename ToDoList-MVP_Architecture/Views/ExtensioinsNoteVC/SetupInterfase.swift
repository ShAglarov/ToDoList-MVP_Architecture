//
//  ExtensionSetupInterfase.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 19.06.2023.
//

import UIKit
import SnapKit

// MARK: - Настройка интерфейса
extension NoteViewController {
    
    func setupTableConstraints() {
        
        navigationItem.title = "Напоминания"
        self.view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
        }
    }
    
    func setupCellConstraints(iconButton: UIButton, titleLabel: UILabel, detailLabel: UILabel, separatorLine: UIView, cell: UITableViewCell) {
        cell.contentView.addSubview(iconButton)
        cell.contentView.addSubview(titleLabel)
        cell.contentView.addSubview(detailLabel)
        cell.contentView.addSubview(separatorLine)
        
        detailLabel.numberOfLines = 0
        separatorLine.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // задаем цвет линии
        
        iconButton.snp.makeConstraints { make in
            // убираем верхний отступ, он нам больше не нужен, так как мы выравниваем по центру
            //make.centerY.equalTo(cell.contentView.snp.centerY)
            make.top.equalTo(cell.contentView.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(cell.contentView.safeAreaLayoutGuide.snp.leading).offset(8)
            make.trailing.equalTo(cell.contentView.safeAreaLayoutGuide.snp.leading).offset(-8)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconButton.snp.centerY)
            make.leading.equalTo(iconButton.snp.trailing).offset(20)
            make.trailing.equalTo(cell.contentView.safeAreaLayoutGuide.snp.trailing).offset(-8)
            make.width.equalToSuperview().offset(-40 - 20 - 8) // Ширина экрана минус отступы и ширина iconButton
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(iconButton.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.height.equalTo(1) // высота линии равна 1
        }
        
        func showDetailView() {
            detailLabel.snp.makeConstraints { make in
                make.top.equalTo(separatorLine.snp.top).offset(10)
                make.leading.equalTo(titleLabel.snp.leading)
                make.trailing.equalTo(titleLabel.snp.trailing)
                make.bottom.equalTo(cell.contentView.snp.bottom).offset(-50)
            }
        }
    }
}
