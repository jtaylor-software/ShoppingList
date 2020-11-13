//
//  Item+Convenience.swift
//  ShoppingList
//
//  Created by Jeremy Taylor on 11/13/20.
//

import Foundation
import CoreData

extension Item {
    convenience init(name: String, isPurchased: Bool = false, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.isPurchased = isPurchased
    }
}
