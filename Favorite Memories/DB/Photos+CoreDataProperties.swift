//
//  Photos+CoreDataProperties.swift
//  Favorite Memories
//
//  Created by Epsilon User on 21/3/21.
//
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos")
    }

    @NSManaged public var albumId: Int16
    @NSManaged public var id: Int16
    @NSManaged public var imageUrl: String
    @NSManaged public var tag: Int16
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var title: String

}

extension Photos : Identifiable {

}
