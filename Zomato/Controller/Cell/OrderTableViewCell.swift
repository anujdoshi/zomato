//
//  OrderTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 02/03/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet var totalAmount: UILabel!
    @IBOutlet var foodOrderOn: UILabel!
    @IBOutlet var foodOrderDetails: UITextView!
    @IBOutlet var restaurentName: UILabel!
    @IBOutlet var restaurentImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
