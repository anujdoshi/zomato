//
//  RestaurantTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 20/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    
    @IBOutlet var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantPhoneNumber: UILabel!
    @IBOutlet weak var restaurantType: UILabel!
    @IBOutlet weak var openingHours: UILabel!
    @IBOutlet weak var restaurantName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        restaurantImage.layer.borderWidth = 1
//        restaurantImage.layer.cornerRadius = restaurantImage.frame.height/2
//        restaurantImage.layer.masksToBounds = false
//        restaurantImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
