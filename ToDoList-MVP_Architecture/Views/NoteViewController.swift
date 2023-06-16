//
//  ViewController.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

// MARK: - ViewController.swift
// ToDoList-MVP_Architecture
// Создан Shamil Aglarov 16.06.2023.
import UIKit
import CoreData

// MARK: - NoteViewProtocol
/// Протокол определяет обязательные методы для отображения заметок
protocol NoteViewProtocol {
    func showLoading() /// Показывает индикатор загрузки
    func hideLoading() /// Скрывает индикатор загрузки
    func set(notes: [Note]) /// Заполняет представление заметками
    func showError(title: String, message: String) /// Отображает сообщение об ошибке
    func addNewNote() /// Добавляет новую заметку
}

// MARK: - NoteViewController
/// Класс NoteViewController обеспечивает отображение списка заметок и взаимодействие с пользователем
class NoteViewController: UIViewController, NoteViewProtocol {
    
    // MARK: - Свойства
    var notes = [Note]() /// Массив заметок
    var presenter: NotePresenterProtocol! /// Презентер для обработки логики отображения заметок
    
    // MARK: - UI элементы
    var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return table
    }()
    
    // MARK: - Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfigureConstraints()
        
//        let testNote = Note(title: "Тестовая заметка", isComplete: true, dueDate: Date(), notes: "Эта заметка добавлена для тестирования работы программы и ее функций")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        
        let cache: CoreDataCacheProtocol = CoreDataHandler(persistentContainer)
        
        // Создаем экземпляр DataRepository и подключаем его к протоколу CoreData
        let dataRepository = DataRepository(cache: cache)
        
        // Инициализируем презентер и подключаем к базе данных
        presenter = NotePresenter(view: self, repository: dataRepository)
        
        presenter.fetchNotes()
        
        // Добавляем новую заметку
//        Task.init {
//            await presenter.saveNote(note: testNote)
//        }
    }
    
    // MARK: - Методы NoteViewProtocol
    func showLoading() {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
    }
    
    func hideLoading() {
        navigationItem.rightBarButtonItem = nil
    }
    
    func set(notes: [Note]) {
        self.notes = notes
        tableView.reloadData() /// Перезагружаем данные таблицы
    }
    
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alertController, animated: true, completion: nil)
    }
    
    func addNewNote() {
        tableView.reloadData() /// Перезагружаем данные таблицы
    }
    
    // MARK: - Настройка интерфейса
    func setupConfigureConstraints() {
        navigationItem.title = "Напоминания"
        self.view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
/// Реализация методов UITableViewDataSource и UITableViewDelegate
extension NoteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.notes
        return cell
    }
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) async {
        if editingStyle == .delete {
            let selectedNote = notes[indexPath.row]
            await presenter.deleteNote(by: selectedNote.id)
            tableView.reloadData()
        }
    }
}
