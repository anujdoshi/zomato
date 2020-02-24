//
//  RestaurentMenuTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class RestaurentMenuTableViewCell: UITableViewCell {
    var foodOrder = [Order]()
    let texts = UILabel(frame: CGRect(x:270,y:80,width: 20,height: 20))
    @IBOutlet var addButtonOutlet: UIButton!
    @IBOutlet var imageViewFood: UIImageView!
    @IBOutlet var foodAddButton: UIButton!
    @IBOutlet var foodPrice: UILabel!
    @IBOutlet var foodName: UILabel!
    @IBOutlet var stepperOutlet: UIStepper!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stepperOutlet.isHidden = true
    }
    func updateUI(){
        imageViewFood.layer.borderWidth = 1.0
        imageViewFood.layer.cornerRadius = 15.0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addButton(_ sender: UIButton) {
        addButtonOutlet.isHidden = true
        stepperOutlet.isHidden = false
        stepperOutlet.maximumValue = 10.0
        stepperOutlet.minimumValue = 0.0

    }
    

    @IBAction func stepperValueChange(_ sender: UIStepper) {
        let order = Order()
        order.foodId = stepperOutlet.tag
        order.qty = Int(sender.value)
        foodOrder.append(order)
        texts.text = ""
        texts.text = "\(Int(sender.value))"
        self.addSubview(texts)
        //print("UIStepper is now \(Int(sender.value))")
    }
}
