//
//  RestaurentMenuTableViewCell.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class RestaurentMenuTableViewCell: UITableViewCell {
    var foodOrder = [Order]()
    var amount:Int = 0
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
        getFoodDetails(id: stepperOutlet.tag)
        addToCart(id: stepperOutlet.tag,qty: Int(sender.value))
    
        foodOrder.append(order)
        texts.text = ""
        texts.text = "\(Int(sender.value))"
        self.addSubview(texts)
        //print("UIStepper is now \(Int(sender.value))")
    }
    func getFoodDetails(id:Int){
        let url = URL(string: "http://192.168.2.226:3002/food/fooddetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["r_id":rid,"email":loginEmail,"f_id":id]
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
                   
            }
        }

        task.resume()
    }
    func addToCart(id:Int,qty:Int){
        let url = URL(string: "http://192.168.2.226:3002/order/addtocart")
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
            //let js = try! JSON(data: data)
            //let responseString = String(data: data, encoding: .utf8)
            DispatchQueue.main.async(){
               
            }
        }

        task.resume()
    }

}
