//
//  Game+CoreDataProperties.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 27/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Game {

    @NSManaged var id: NSNumber?
    @NSManaged var imageUrl: String?
    @NSManaged var name: String?
    @NSManaged var viewers: NSNumber?

}
