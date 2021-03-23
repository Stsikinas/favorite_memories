//
//  DatabaseService.swift
//  Favorite Memories
//
//  Created by Epsilon User on 12/3/21.
//

import Foundation
import CoreData


class DatabaseService {
    
    public init() {}
    
    // Singleton
    static let shared = DatabaseService()

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Favorite_Memories")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var dbContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext () {
        if dbContext.hasChanges {
            do {
                try dbContext.save()
                print("Items have been saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    /// Save albums that have been fetched from the API
    /// - Parameters:
    ///   - albums: The JSON representation of the albums
    /// - Returns: Save has been completed
    func save(albums: [[String: Any]], completion: @escaping (Bool) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            guard let albumEntity = NSEntityDescription.entity(forEntityName: "Albums", in: privateContext) else {
                completion(false)
                return
            }
            for album in albums {
                let albumObject = NSManagedObject(entity: albumEntity, insertInto: privateContext)
            
                albumObject.setValue(album["id"], forKey: "id")
                albumObject.setValue(album["title"], forKey: "title")
                // Initialize page (it's 1, not 0)
                albumObject.setValue(1, forKey: "pageLoaded")
            }
            
            do {
                try privateContext.save()
                completion(true)
            } catch {
                print("Unable to save context | Error: \(error)")
                completion(false)
            }
        }
        
    }
    
    
    /// Get the current page of the selected album to perform paging
    /// - Parameters:
    ///   - albumId: The ID of the album to read the page state
    /// - Returns: The number of page itself
    func getPage(_ albumId: Int16, completion: @escaping (Int16) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            let fetchAlbumsRequest = NSFetchRequest<NSManagedObject>(entityName: "Albums")
            let predicate = NSPredicate(format: "id = %@", argumentArray: [albumId])
            fetchAlbumsRequest.predicate = predicate
            fetchAlbumsRequest.fetchLimit = 1
            do {
                if let albums = try privateContext.fetch(fetchAlbumsRequest) as? [Albums] {
                    if let albumToRetrieve = albums.first {
                        completion(albumToRetrieve.pageLoaded)
                    } else {
                        completion(0)
                    }
                } else {
                    completion(0)
                }
            } catch {
                print("Unable to update Loaded Context")
                completion(0)
            }
        }
    }
    
    
    /// Update the page property of the Album table, when the fetch is successful
    /// - Parameters:
    ///   - albumId: The ID of the album to read the page state
    ///   - page: The new page state of the album
    func update(albumId: Int16, _ page: Int16) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            let fetchAlbumsRequest = NSFetchRequest<NSManagedObject>(entityName: "Albums")
            let predicate = NSPredicate(format: "id = %@", argumentArray: [albumId])
            fetchAlbumsRequest.predicate = predicate
            do {
                if let albums = try privateContext.fetch(fetchAlbumsRequest) as? [Albums] {
                    if let albumToUpdate = albums.first {
                        albumToUpdate.pageLoaded = page
                        try privateContext.save()
                    }

                }
            } catch {
                print("Unable to update Loaded Context")
            }
        }
    }
    
    /// Save photos that have been fetched from the API
    /// - Parameters:
    ///   - photos: The JSON representation of the photos
    /// - Returns: Save has been completed
    func save(photos: [[String: Any]], completion: @escaping (Bool) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            guard let photosEntity = NSEntityDescription.entity(forEntityName: "Photos", in: privateContext) else {
                completion(false)
                return
            }
            for photo in photos {
                let photoObject = NSManagedObject(entity: photosEntity, insertInto: privateContext)
            
                photoObject.setValue(photo["albumId"], forKey: "albumId")
                photoObject.setValue(photo["id"], forKey: "id")
                photoObject.setValue(photo["title"], forKey: "title")
                photoObject.setValue(photo["url"], forKey: "imageUrl")
                photoObject.setValue(photo["thumbnailUrl"], forKey: "thumbnailUrl")
                photoObject.setValue(Int16.random(in: 0...2), forKey: "tag")
            }
            
            do {
                try privateContext.save()
                completion(true)
            } catch {
                print("Unable to save context | Error: \(error)")
                completion(false)
            }
        }
    }
    
    
    /// Function to retrieve the album model in an array. This is triggered to show albums, but also to initialize them, if it returns empty or null
    /// - Returns: Optional array of albums
    func readAlbums(completion: @escaping ([Albums]?) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            let fetchAlbumsRequest = NSFetchRequest<NSManagedObject>(entityName: "Albums")
            let sorting = NSSortDescriptor(key: "id", ascending: false)
            fetchAlbumsRequest.sortDescriptors = [sorting]
            do {
                if let albums = try privateContext.fetch(fetchAlbumsRequest) as? [Albums] {
                    completion(albums)
                }
            } catch {
                print("Unable to read albums")
                completion(nil)
            }
        }
    }
    
    
    /// Function to retrieve the photo model in an array. This is triggered to show photos, but also to initialize them, if it returns empty or null
    /// - Parameters:
    ///   - albumId: The ID of the album to retrieve the photos
    /// - Returns: Optional array of photos
    func readPhotos(albumId: Int16, completion: @escaping ([Photos]?) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            let fetchPhotosRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
            let predicate = NSPredicate(format: "albumId = %@", argumentArray: [albumId])
            fetchPhotosRequest.predicate = predicate
            // Make desceding sort, to have a logical order in UI (eg, when refreshing)
            let sorting = NSSortDescriptor(key: "id", ascending: false)
            fetchPhotosRequest.sortDescriptors = [sorting]
            do {
                if let photos = try privateContext.fetch(fetchPhotosRequest) as? [Photos] {
                    completion(photos)
                } else {
                    completion(nil)
                }
            } catch {
                print("Unable to read albums")
                completion(nil)
            }
        }
    }
    
    
    func update(photoID: Int16, with newTitle: String, completion: @escaping (Bool) -> ()) {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = dbContext.persistentStoreCoordinator
        privateContext.perform {
            let fetchPhotoRequest = NSFetchRequest<NSManagedObject>(entityName: "Photos")
            let predicate = NSPredicate(format: "id = %@", argumentArray: [photoID])
            fetchPhotoRequest.predicate = predicate
            do {
                if let photos = try privateContext.fetch(fetchPhotoRequest) as? [Photos] {
                    if let photoToUpdate = photos.first {
                        photoToUpdate.title = newTitle
                        try privateContext.save()
                        completion(true)
                    } else {
                        completion(false)
                    }

                } else {
                    completion(false)
                }
            } catch {
                print("Unable to update Photo Title")
                completion(false)
            }
        }
    }
    
}
