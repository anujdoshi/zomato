//
//  AddToCartDetailsTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 28/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class AddToCartDetailsTableViewCell: UITableViewCell {

    @IBOutlet var qtyLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var foodName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
