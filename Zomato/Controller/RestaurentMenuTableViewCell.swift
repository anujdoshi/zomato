//
//  RestaurentMenuTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class RestaurentMenuTableViewCell: UITableViewCell {
    let texts = UILabel(frame: CGRect(x:270,y:80,width: 20,height: 20))
    @IBOutlet var addButtonOutlet: UIButton!
    @IBOutlet var imageViewFood: UIImageView!
    @IBOutlet var foodAddButton: UIButton!
    @IBOutlet var foodPrice: UILabel!
    @IBOutlet var foodName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
        
        let steeper = UIStepper(frame: CGRect(x:290, y: 80, width: 0, height: 0))
        steeper.minimumValue = 1.0
        steeper.maximumValue = 10.0
        steeper.tintColor = UIColor.red
        steeper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)

        self.addSubview(steeper)
    }
    
    @objc func stepperValueChanged(_ sender:UIStepper!)
    {
        
        texts.text = ""
        texts.text = "\(Int(sender.value))"
        self.addSubview(texts)
        print("UIStepper is now \(Int(sender.value))")
    }

}
