//
//  ShoppingListTableViewController.swift
//  ShoppingList
//
//  Created by Jeremy Taylor on 11/13/20.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        ShoppingController.shared.fetchedResultsController.delegate = self
        searchBar.delegate = self
    }
    
    @IBAction func addItemButtonTapped(_ sender: Any) {
        presentAddItemAlert()
    }
    
    func presentAddItemAlert() {
        let alertController = UIAlertController(title: "Add Item", message: "Please add an item to your shopping list", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "Enter item name here..."
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addItemAction = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let itemName = alertController.textFields?[0].text else {return}
            ShoppingController.shared.createItem(name: itemName)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addItemAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return ShoppingController.shared.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ShoppingController.shared.fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingCell", for: indexPath) as? ShoppingListTableViewCell else {return UITableViewCell()}
        
        let item = ShoppingController.shared.fetchedResultsController.object(at: indexPath)
        cell.delegate = self
        cell.item = item
        
        return cell
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = ShoppingController.shared.fetchedResultsController.object(at: indexPath)
            ShoppingController.shared.deleteItem(item: itemToDelete)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ShoppingController.shared.fetchedResultsController.sectionIndexTitles[section] == "0" ? "Not Purchased" : "Purchased"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 7
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

extension ShoppingListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let predicate = NSPredicate(format: "%K CONTAINS[c] %@", argumentArray: ["name", searchText])
        ShoppingController.shared.fetchedResultsController.fetchRequest.predicate = predicate
        
        performFetch()
        
        
        if searchText.isEmpty {
            ShoppingController.shared.fetchedResultsController.fetchRequest.predicate = nil
            performFetch()
        }
    }
    
    func performFetch() {
        do {
            try ShoppingController.shared.fetchedResultsController.performFetch()
            tableView.reloadData() // This works but why doesn't the FRC delegate do this???
        } catch {
            print(error)
            print(error.localizedDescription)
        }
    }
}

extension ShoppingListTableViewController: ShoppingListCellDelegate {
    func isPurchaseButtonTapped(sender: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else {return}
        let item = ShoppingController.shared.fetchedResultsController.object(at: indexPath)
        ShoppingController.shared.toggleisPurchased(item: item)
    }
}

extension ShoppingListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSet, with: .automatic)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { break }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else { break }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { break }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { break }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
