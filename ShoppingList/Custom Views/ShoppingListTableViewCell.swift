//
//  ShoppingListTableViewCell.swift
//  ShoppingList
//
//  Created by Jeremy Taylor on 11/13/20.
//

import UIKit

protocol ShoppingListCellDelegate: AnyObject {
    func isPurchaseButtonTapped(sender: UITableViewCell)
}

class ShoppingListTableViewCell: UITableViewCell {
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var isPurchasedButton: UIButton!
    
    var item: Item? {
        didSet {
            updateViews()
            
        }
    }
    
    weak var delegate: ShoppingListCellDelegate?
    
    @IBAction func isPurchasedButtonTapped(_ sender: Any) {
        delegate?.isPurchaseButtonTapped(sender: self)
    }
    
    func updateViews() {
        guard let item = item else {return}
        itemNameLabel.text = item.name
        updateIsPurchased(item: item)
        
    }
    
    func updateIsPurchased(item: Item) {
        item.isPurchased ? (isPurchasedButton.setImage(UIImage(named: "purchased"), for: .normal)) : (isPurchasedButton.setImage(UIImage(named: "notpurchased"), for: .normal))
    }
}
