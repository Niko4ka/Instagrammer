import CoreData
import UIKit

final class CoreDataManager {
    
    // Variables
    static let instance = CoreDataManager(modelName: "Instagrammer")
    private let modelName: String
    let persistentContainer: NSPersistentContainer
    public let context: NSManagedObjectContext
//    public let mainManagedObjectContext: NSManagedObjectContext
//    public let childManagedObjectContext: NSManagedObjectContext

    // Init
    private init(modelName: String) {
        self.modelName = modelName
        
        persistentContainer = NSPersistentContainer(name: modelName)
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        })

        context = persistentContainer.viewContext
//        mainManagedObjectContext = persistentContainer.viewContext
//        childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        childManagedObjectContext.parent = mainManagedObjectContext
    }
    
    public func save(context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error - \(error), \(error.userInfo)")
            }
        }
    }
    
    public func saveInBackgroundContext(handler: @escaping (NSManagedObjectContext)->()) {

        persistentContainer.performBackgroundTask { (backgroundContext) in
            
            handler(backgroundContext)
            
            do {
                try backgroundContext.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    public func createObject<T: NSManagedObject>(from entity: T.Type) -> T {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return object
    }
    
    public func createObject<T: NSManagedObject>(from entity: T.Type, inContext context: NSManagedObjectContext) -> T {
        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entity), into: context) as! T
        return object
    }
    
    public func delete(object: NSManagedObject) {
        context.delete(object)
        save(context: context)
    }
    
    public func clearAllObjects<T: NSManagedObject>(ofType type: T.Type) {
        let objects = fetchData(for: type)
        objects.forEach { context.delete($0) }
        save(context: context)
    }
    
    public func fetchData<T: NSManagedObject>(for entity: T.Type, predicate: NSPredicate? = nil) -> [T] {

        let request: NSFetchRequest<T>
        var fetchedResult = [T]()
        
        if #available(iOS 10.0, *) {
            request = entity.fetchRequest() as! NSFetchRequest<T>
        } else {
            let entityName = String(describing: entity)
            request = NSFetchRequest(entityName: entityName)
        }
        
        request.predicate = predicate
        
        if entity == PostEntity.self {
            let sortDescriptor = NSSortDescriptor(key: "createdTime", ascending: false)
            request.sortDescriptors = [sortDescriptor]
        }
        
        do {
            fetchedResult = try context.fetch(request)
        } catch {
            debugPrint("Couldn't fetch \(error.localizedDescription)")
        }
        
        return fetchedResult
    }
    
    public func postExists(with id: String) -> Bool {
        
        let predicate = NSPredicate(format: "%K == %@", "id", "\(id)")
        let existingPosts = CoreDataManager.instance.fetchData(for: PostEntity.self, predicate: predicate)

        return existingPosts.count > 0
    }
    
    public func updatePost(withID id: String, newIntValue: Int, forKey key: String) {

            guard let post = getPost(withID: id) else { return }
            let newValue = Int16(newIntValue)
            post.setValue(newValue, forKey: key)
            save(context: context)
    }
    
    public func updatePost(withID id: String, newValue: Any, forKey key: String) {

            guard let post = getPost(withID: id) else { return }
            post.setValue(newValue, forKey: key)
            save(context: context)
    }
    
    public func updateUser(withID id: String, newValue: Any, forKey key: String) {

            guard let user = getUser(withID: id) else { return }
            user.setValue(newValue, forKey: key)
            save(context: context)
    }
    
    // MARK: - Private
    
    private func getPost(withID id: String) -> PostEntity? {
        let predicate = NSPredicate(format: "%K == %@", "id", "\(id)")
        let post = CoreDataManager.instance.fetchData(for: PostEntity.self, predicate: predicate).first
        return post
    }
    
    private func getUser(withID id: String) -> UserEntity? {
        let predicate = NSPredicate(format: "%K == %@", "id", "\(id)")
        let user = CoreDataManager.instance.fetchData(for: UserEntity.self, predicate: predicate).first
        return user
    }
    
}

