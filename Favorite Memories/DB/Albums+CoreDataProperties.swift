//
//  Albums+CoreDataProperties.swift
//  Favorite Memories
//
//  Created by Epsilon User on 19/3/21.
//
//

import Foundation
import CoreData


extension Albums {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Albums> {
        return NSFetchRequest<Albums>(entityName: "Albums")
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String
    @NSManaged public var pageLoaded: Int16

}

extension Albums : Identifiable {

}
