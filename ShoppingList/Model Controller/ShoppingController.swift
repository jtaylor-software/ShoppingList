//
//  ShoppingController.swift
//  ShoppingList
//
//  Created by Jeremy Taylor on 11/13/20.
//

import Foundation
import CoreData

class ShoppingController {
    static let shared = ShoppingController()
    
    let fetchedResultsController: NSFetchedResultsController<Item> = {
        
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let purchasedSort = NSSortDescriptor(key: "isPurchased", ascending: false)
        fetchRequest.sortDescriptors = [purchasedSort]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "isPurchased", cacheName: nil)
    }()
    
    init() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }
    
    // MARK: - CRUD
    
    func createItem(name: String) {
        _ = Item(name: name)
        saveToPersistentStore()
    }
    
    func updateItem(item: Item, name: String, isPuchased: Bool) {
        item.name = name
        item.isPurchased = isPuchased
        saveToPersistentStore()
    }
    
    func deleteItem(item: Item) {
        CoreDataStack.context.delete(item)
        saveToPersistentStore()
    }
    
    func toggleisPurchased(item: Item) {
        item.isPurchased.toggle()
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }
} // End of class
