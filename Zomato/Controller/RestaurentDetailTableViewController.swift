//
//  RestaurentDetailTableViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
struct addToCart:Encodable {
    var f_id:Int = 0
    var r_id:Int = 0
    var email:String = ""
}
var totalMainAmount = 0
var totalItem = 0

var uiView:UIView = UIView()
let itemLabel = UILabel(frame: CGRect(x:3,y:10,width: 100,height: 30))
let priceLabel = UILabel(frame: CGRect(x: 3, y: 30, width: 90, height: 30))
let viewCart = UIButton()

class RestaurentDetailTableViewController: UITableViewController{
    var myTableView: UITableView!
    var foodOrder = [Cart]()
    var foodMenuArray = [RestaurentMenuModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //For Register a custom cell
        tableView.register(UINib(nibName: "RestaurentMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        //For Updating UI
        updateUI()
    }
    
    func updateUI(){
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
        viewCart.frame = CGRect(x: view.bounds.maxX-200, y: 0, width: 200, height: 100)
        uiview.backgroundColor = Color.red
        uiview.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.text = ""
        itemLabel.font = UIFont.boldSystemFont(ofSize: 30)
        itemLabel.textColor = UIColor.white
        priceLabel.text = ""
        priceLabel.font = UIFont.boldSystemFont(ofSize: 30)
        priceLabel.textColor = UIColor.white
        viewCart.setTitleColor(UIColor.white, for: .normal)
        viewCart.setTitle("View Cart", for: .normal)
        viewCart.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        viewCart.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
        uiview.addSubview(itemLabel)
        uiview.addSubview(priceLabel)
        uiview.addSubview(viewCart)
        tableView.tableFooterView = uiview
        viewCart.addTarget(self, action: #selector(self.viewCartButton), for: .touchUpInside)
        uiview.isHidden = true
        uiView = uiview
        getRestaurentDetailApi(id: restaurentId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myTableView{
            return foodOrder.count
        }
        return foodMenuArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == myTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath) as! AddToCartDetailsTableViewCell
            cell.foodName.text = "\(foodOrder[indexPath.row].foodName)"
            cell.qtyLabel.text = "\(foodOrder[indexPath.row].qty)"
            cell.priceLabel.text = "\(foodOrder[indexPath.row].amount)"
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestaurentMenuTableViewCell
            let urlString = try! foodMenuArray[indexPath.row].foodImage.asURL()
            let data = NSData(contentsOf: urlString)
            cell.foodName.text = foodMenuArray[indexPath.row].foodName
            cell.foodPrice.text = "₹\(foodMenuArray[indexPath.row].foodAmount)"
            cell.imageViewFood.image = UIImage(data: data! as Data)
            cell.steeperOutlet.tag = foodMenuArray[indexPath.row].foodId
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        totalMainAmount = 0
        foodOrder.removeAll()
        deletCartDetails()
    }
    
    //Api Call's
    func getRestaurentDetailApi(id:Int){
        let url = URL(string: "http://192.168.2.226:3000/res/restaurents/resdetail")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["r_id":id]
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
            DispatchQueue.main.async(){
                let url = js[0]["photos"].string
                let urlString = try! url?.asURL()
                _ = NSData(contentsOf: urlString!)
                for i in 0..<js.count{
                    let foodId = js[i]["f_id"]
                    let foodName = js[i]["food_name"]
                    let foodPrice = js[i]["amount"]
                    let foodType = js[i]["food_type"]
                    let foodPhoto = js[i]["food_img"]
                    let foodModel = RestaurentMenuModel()
                    foodModel.foodId = foodId.int!
                    foodModel.foodName = foodName.string!
                    foodModel.foodType = foodType.string!
                    foodModel.foodAmount = foodPrice.int!
                    foodModel.foodImage = foodPhoto.string!
                    self.tableView.reloadData()
                    self.foodMenuArray.append(foodModel)
                }
            }
        }
        
        task.resume()
    }
    func cartDetailApi(r_id:Int,email:String){
        
        let url = URL(string: "http://192.168.2.226:3000/order/cartdetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["r_id":r_id,"email":email]
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
            for i in 0..<js.count{
                if js["message"] != "no items !"{
                        DispatchQueue.main.async(){
                            let cart = Cart()
                            cart.foodId = js[i]["f_id"].int!
                            cart.qty = js[i]["qty"].int!
                            cart.amount = js[i]["amount"].int!
                            cart.total_amount = js[i]["total_amount"].int!
                            self.getFoodDetails(id: js[i]["f_id"].int!)
                            self.foodOrder.append(cart)
                        }

                }
            }
        }
        task.resume()
    }
    @objc func viewCartButton(){
        foodOrder.removeAll()
        cartDetailApi(r_id: rid, email: loginEmail)
        
        let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)

        let view = UIView(frame: CGRect(x: 8.0, y: 8.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 120.0))
        DispatchQueue.main.async {
            
            self.myTableView = UITableView(frame: CGRect(x: 8.0, y: 8.0, width: actionSheet.view.bounds.size.width - 8.0 * 4.5, height: 300))
            self.myTableView.register(UINib(nibName: "AddToCartDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCell")
            self.myTableView.dataSource = self
            self.myTableView.delegate = self
            view.addSubview(self.myTableView)
            view.backgroundColor = UIColor.white
            actionSheet.view.addSubview(view)

            actionSheet.addAction(UIAlertAction(title: "Place Order", style: .default, handler: { (UIAlertAction) in
                //
                for i in 0..<self.foodOrder.count{
                    let f_id = self.foodOrder[i].foodId
                    let qty = self.foodOrder[i].qty
                    self.placeOrder(f_id: f_id, qty: qty)

                }
            }))
            let height:NSLayoutConstraint = NSLayoutConstraint(item: actionSheet.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.80)
            actionSheet.view.addConstraint(height);
            actionSheet.addAction(UIAlertAction(title: "Total Price\(totalMainAmount)", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    func deletCartDetails(){
        let url = URL(string: "http://192.168.2.226:3000/order/delcartdetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["r_id":rid,"email":loginEmail]
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
            _ = try! JSON(data: data)
            
        }
        task.resume()
    }

   func getFoodDetails(id:Int){
       let url = URL(string: "http://192.168.2.226:3000/food/fooddetails")
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
          
           
           
           DispatchQueue.main.async(){
            for i in 0..<self.foodOrder.count{
                if self.foodOrder[i].foodId == id{
                    self.foodOrder[i].foodName = json[0]["food_name"].string!
                    self.myTableView.reloadData()
                }
                
            }
            
           }
            
       }
       
       task.resume()
       
   }
   func placeOrder(f_id:Int,qty:Int){
        let url = URL(string: "http://192.168.2.226:3000/orderlist/addtoorderlist")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["r_id":rid,"f_id":f_id,"email":loginEmail,"qty":qty,"address":"","payment_type":"Cash","total_amount":totalMainAmount]
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
           
            
            
            DispatchQueue.main.async(){
             
                if json["message"] == "Order added to Order List"{
                    let alert = UIAlertController(title: "Place Order", message: "Your Order successfully placed.Our Caption sortly order your food at your place. Thank You for chossing us", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler:nil)
                    let cancelOrder = UIAlertAction(title: "Cancel Order", style: .cancel) { (UIAlertAction) in
                        //
                    }
                    alert.addAction(action)
                    alert.addAction(cancelOrder)
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Place Order", message: "Something went wrong please try again!!!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        task.resume()
    }
}
