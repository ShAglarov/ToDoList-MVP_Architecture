//
//  CoreDataHandler.swift
//  ToDoList-MVP_Architecture
//
//  Created by Shamil Aglarov on 16.06.2023.
//

import CoreData

// MARK: - CoreDataManagerProtocol
/// Протокол для моделей, которые могут быть управляемы с помощью `CoreDataManager`.
protocol CoreDataManagerProtocol {
    
    associatedtype Entity: NSManagedObject
    var id: UUID { get }
    
    /// Конвертирует модель в `NSManagedObject`.
    func toEntity(context: NSManagedObjectContext) -> Entity
    
    /// Обновляет `NSManagedObject` из модели.
    func updateEntity(_ entity: Entity)
    
    /// Инициализирует модель из `NSManagedObject`.
    init(from entity: Entity)
    
    /// Создает новый экземпляр модели.
    static func newInstance(id: UUID,
                            title: String,
                            isComplete: Bool,
                            dueDate: Date,
                            note: String) -> Self
}

// MARK: - CoreDataManager
/// Менеджер для управления моделями, которые совместимы с `CoreDataManagerProtocol`.
final class CoreDataManager<Model: CoreDataManagerProtocol> where Model.Entity: NSManagedObject {
    
    private let persistentContainer: NSPersistentContainer
    
    /// Инициализирует менеджер с заданным `NSPersistentContainer`.
    init(_ persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    /// Извлекает все экземпляры `Model` из базы данных.
    func fetch(completion: @escaping (Result<[Model], Error>) -> Void) {
        let fetchRequest = Model.Entity.fetchRequest() as! NSFetchRequest<Model.Entity>
        
        // Сортировка по убыванию даты
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        persistentContainer.viewContext.perform {
            do {
                let entities = try self.persistentContainer.viewContext.fetch(fetchRequest)
                let models = entities.map(Model.init)
                completion(.success(models))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// Сохраняет экземпляр `Model` в базу данных.
    func save(model: Model, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            _ = model.toEntity(context: context)
            
            do {
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    /// Обновляет экземпляр `Model` в базе данных по заданному идентификатору.
    func update(id: UUID, with newModel: Model, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Model.Entity.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        context.perform {
            do {
                let entities = try context.fetch(fetchRequest) as! [Model.Entity]
                guard let entity = entities.first else {
                    // Ошибка обработки: объект с заданным идентификатором не найден
                    return
                }
                
                // Обновляем сущность
                newModel.updateEntity(entity)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    /// Удаляет экземпляр `Model` из базы данных по заданному идентификатору.
    func delete(by id: UUID, completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Model.Entity.self))
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        context.perform {
            do {
                let entities = try context.fetch(fetchRequest) as! [NSManagedObject]
                guard let entity = entities.first else { return }
                
                context.delete(entity)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
