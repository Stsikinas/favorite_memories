//
//  DatabaseServiceUnitTests.swift
//  Favorite MemoriesTests
//
//  Created by Epsilon User on 22/3/21.
//

import CoreData
@testable import Favorite_Memories

class DatabaseServiceUnitTests: DatabaseService {
    
    override init() {
        super.init()
        
        // Keep store in-memory (disappear data in termination ;) )
        let persisentDescriptor = NSPersistentStoreDescription()
        persisentDescriptor.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "Favorite_Memories")
        
        container.persistentStoreDescriptions = [persisentDescriptor]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        persistentContainer = container
    }

}
