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

class RestaurentMenuTableViewCell: UITableViewCell{
    //Extra Variable
    var foodOrder = [Order]()
    let order = Order()
    let cart = Cart()
    var oldValue:Int = 0
    var amount:Int = 0
    var count = 0
    var stepperState:GMStepper.State?
    //Configure a custom text label
    let texts = UILabel(frame: CGRect(x:270,y:80,width: 20,height: 20))
    
    //Outlet's
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
    /*
    // MARK: - Update UI
    */
    func updateUI(){
        imageViewFood.layer.borderWidth = 1.0
        imageViewFood.layer.cornerRadius = 15.0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    /*
    // MARK: - Add Button Action
    */
    @IBAction func addButton(_ sender: UIButton) {
        
        addButtonOutlet.isHidden = true
        steeperOutlet.isHidden = false
        uiView.isHidden = false
        steeperOutlet.minimumValue = 0.0
        steeperOutlet.maximumValue = 10.0
        
    }
    /*
    // MARK: - Stepper Value Change Function
    */
    @objc func valueChanged(stepper: GMStepper){
        
        if steeperOutlet.value == 0{
            addButtonOutlet.isHidden = false
            steeperOutlet.isHidden = true
            //uiView.isHidden = true
        }
        if Int(stepper.value) > oldValue{
            count = 1
        }else{
            count = 2
        }
        oldValue = Int(stepper.value)
        getFoodDetails(id: steeperOutlet.tag,qty: Int(stepper.value))
    }
    /*
    // MARK: - API
    */
    func getFoodDetails(id:Int,qty:Int){
        let url = URL(string: "\(urlAPILocation)food/fooddetails")
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
            
            
            DispatchQueue.main.async(){
                
                self.addToCart(id: id,qty: qty,amount:json[0]["amount"].int!)
                if self.count == 1{
                    
                    totalItem = totalItem + qty
                    //itemLabel.text = "\(totalItem) | Items"
                    totalMainAmount = totalMainAmount + (self.amount)
                    priceLabel.text = "₹\(totalMainAmount)"
                }else if self.count == 2{
                    totalItem = totalItem - qty
                    //itemLabel.text = "\(totalItem) | Items"
                    totalMainAmount = totalMainAmount - (self.amount)
                    priceLabel.text = "₹\(totalMainAmount)"
                }
                
            }
        }
        
        task.resume()
        
    }
    /*
    // MARK: - API(Add To Cart)
    */
    func addToCart(id:Int,qty:Int,amount:Int){
        
        let url = URL(string: "\(urlAPILocation)order/addtocart")
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
            let js = try! JSON(data: data)
            if js["message"] == "Order added to Cart"{
                
            }
        }

        task.resume()
    }
    
}
