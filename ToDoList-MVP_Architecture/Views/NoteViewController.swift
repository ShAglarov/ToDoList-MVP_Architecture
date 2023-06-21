//
//  ViewController.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import UIKit
import CoreData

// MARK: - NoteViewProtocol
/// Протокол, определяющий обязательные методы для обновления и отображения заметок.
protocol NoteViewProtocol {
    var notes: [Note] { get set }
    
    /// Обновляет заметку в массиве по определенному индексу.
    func updateNoteInArray(at indexPath: IndexPath, with newNote: Note)
    
    /// Перезагружает определенные строки в tableView.
    func didReloadRows(at indexPath: IndexPath)
    
    /// Показывает индикатор загрузки.
    func showLoading()
    
    /// Скрывает индикатор загрузки.
    func hideLoading()
    
    /// Устанавливает массив заметок.
    func set(notes: [Note])
    
    /// Показывает ошибку с определенным заголовком и сообщением.
    func showError(title: String, message: String)
    
    /// Вставляет новую заметку в массив и перезагружает соответствующую строку в tableView.
    func insertNoteInArrayAndReload(at indexPath: IndexPath, with note: Note)
}

class NoteViewController: UIViewController, NoteViewProtocol {
    
    var selectedIndexPath: IndexPath?
    
    @MainActor var notes = [Note]()
    var presenter: NotePresenterProtocol!
    
    /// Инициализирует tableView и регистрирует ячейку.
    var tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Устанавливает ограничения для tableView.
        setupTableConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        /// Инициализирует persistentContainer, manager и dataRepository, а затем создает презентер.
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let manager: CoreDataManager<Note> = CoreDataManager(persistentContainer)
        let dataRepository = DataRepository(manager: manager)
        presenter = NotePresenter(view: self, repository: dataRepository)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Пытается получить заметки при появлении представления.
        presenter.fetchNotes()

    }
    
    // MARK: - Методы NoteViewProtocol

    /// Показывает индикатор загрузки в правой части навигационной панели.
    func showLoading() {
        DispatchQueue.main.async {
            let activityIndicatorView = UIActivityIndicatorView(style: .medium)
            activityIndicatorView.startAnimating()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        }
    }
    
    /// Скрывает индикатор загрузки и вместо него отображает кнопку добавления.
    func hideLoading() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(actionBarButtonAdd))
    }
    
    /// Устанавливает новый массив заметок и перезагружает tableView.
    func set(notes: [Note]) {
        self.notes = notes
        tableView.reloadData()
    }
    
    /// Отображает всплывающее окно с ошибкой.
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /// Обновляет определенную заметку в массиве.
    func updateNoteInArray(at indexPath: IndexPath, with newNote: Note) {
        self.notes[indexPath.row] = newNote
    }
    
    /// Перезагружает определенные строки в tableView.
    func didReloadRows(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
