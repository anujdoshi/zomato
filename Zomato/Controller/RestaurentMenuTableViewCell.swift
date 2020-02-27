//
//  RestaurentMenuTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
import GMStepper
import PureLayout
protocol PassPrice {
    func pass(price:Int,qty:Int)
}
protocol deleteprice {
    func delete(price:Int)
}

class RestaurentMenuTableViewCell: UITableViewCell {
    var foodOrder = [Order]()
    var totalArray = [Cart]()
    let order = Order()
    var amount:Int = 0
    var passdelegate:PassPrice?
    var deletedelegate:deleteprice?
    let texts = UILabel(frame: CGRect(x:270,y:80,width: 20,height: 20))
    
    @IBOutlet var steeperOutlet: GMStepper!
    @IBOutlet var addButtonOutlet: UIButton!
    @IBOutlet var imageViewFood: UIImageView!
    @IBOutlet var foodAddButton: UIButton!
    @IBOutlet var foodPrice: UILabel!
    @IBOutlet var foodName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        steeperOutlet.isHidden = true
        steeperOutlet.addTarget(self, action: #selector(self.valueChanged(stepper:)), for: .valueChanged)
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
        steeperOutlet.isHidden = false
        uiView.isHidden = false
        steeperOutlet.minimumValue = 0.0
        steeperOutlet.maximumValue = 10.0
        
    }
    
    @objc func valueChanged(stepper: GMStepper){
        
        if steeperOutlet.value == 0{
            addButtonOutlet.isHidden = false
            steeperOutlet.isHidden = true
            //uiView.isHidden = true
        }else{
            
        }
        
        
        getFoodDetails(id: steeperOutlet.tag,qty: Int(stepper.value))
        
        
    }
    func countAmount(){
        print("Count:",foodOrder.count)
//        totalMainAmount = 0
//        for i in 0..<foodOrder.count{
//            print(foodOrder[i].amount)
//            print("Count:",foodOrder.count)
//            totalMainAmount = totalMainAmount + (foodOrder[i].amount)
//        }
//        priceLabel.text = "\(totalMainAmount)"
    }
    func getFoodDetails(id:Int,qty:Int){
        
        let url = URL(string: "http://192.168.2.226:3005/food/fooddetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["f_id":id]
        request.httpBody = parameters.percentEncoded()
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
            let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            self.amount = json[0]["amount"].int!
            //self.addToCart(id: id,qty: qty,amount:json[0]["amount"].int!)
            DispatchQueue.main.async(){
                
                
                self.order.foodId = id
                self.order.qty = qty
                self.order.amount = self.amount
                self.passdelegate?.pass(price:self.amount,qty: qty)
                self.foodOrder.append(self.order)
                //self.countAmount()
                
            }
        }
        
        task.resume()
        
    }
    func addToCart(id:Int,qty:Int,amount:Int){
        
        let url = URL(string: "http://192.168.2.226:3005/order/addtocart")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let parameters: [String: Any] = ["r_id":rid,"email":loginEmail,"f_id":id,"qty":qty,"amount":amount,"total_amount":(amount * qty)]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
        }

        task.resume()
    }
    
}
