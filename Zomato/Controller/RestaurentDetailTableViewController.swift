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
let itemLabel = UILabel(frame: CGRect(x:3,y:10,width: 70,height: 30))
let priceLabel = UILabel(frame: CGRect(x: 3, y: 30, width: 70, height: 30))
let viewCart = UIButton(frame: CGRect(x: 100, y: 20, width: 80, height: 50))
class RestaurentDetailTableViewController: UITableViewController,PassPrice {
    func pass(price: Int, qty: Int) {
        totalMainAmount = totalMainAmount + (price * qty)
        priceLabel.text = "\(totalMainAmount)"
    }
    
   
    var foodMenuArray = [RestaurentMenuModel]()
    var foodOrder = [Cart]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = RestaurentMenuTableViewCell()
        vc.passdelegate = self
        
        tableView.register(UINib(nibName: "RestaurentMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
        uiview.backgroundColor = Color.red
        uiview.translatesAutoresizingMaskIntoConstraints = false
        itemLabel.text = ""
        priceLabel.text = ""
        viewCart.setTitleColor(UIColor.black, for: .normal)
        viewCart.setTitle("View Cart", for: .normal)
        uiview.addSubview(itemLabel)
        uiview.addSubview(priceLabel)
        uiview.addSubview(viewCart)
        tableView.tableFooterView = uiview
        uiview.isHidden = true
        uiView = uiview
        getRestaurentDetailApi(id: restaurentId)
        cartDetailApi(r_id: restaurentId, email: loginEmail)
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodMenuArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestaurentMenuTableViewCell
        let urlString = try! foodMenuArray[indexPath.row].foodImage.asURL()
        let data = NSData(contentsOf: urlString)
        cell.foodName.text = foodMenuArray[indexPath.row].foodName
        cell.foodPrice.text = "💰\(foodMenuArray[indexPath.row].foodAmount)"
        cell.imageViewFood.image = UIImage(data: data! as Data)
        cell.steeperOutlet.tag = foodMenuArray[indexPath.row].foodId
        print(cell.steeperOutlet.value)
        for i in 0..<foodOrder.count{
            if foodOrder[i].foodId == foodMenuArray[indexPath.row].foodId{
                print(foodOrder[i].foodId,"=",foodMenuArray[indexPath.row].foodId)
                cell.addButtonOutlet.isHidden = true
                cell.steeperOutlet.isHidden = false
                cell.steeperOutlet.value = Double(foodOrder[i].qty)
                uiView.isHidden = false
            }else{
                cell.addButtonOutlet.isHidden = false
                cell.steeperOutlet.isHidden = true
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func getRestaurentDetailApi(id:Int){
        let url = URL(string: "http://192.168.2.226:3005/res/restaurents/resdetail")
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
//            var remainingApiCalls = js.count
            
            DispatchQueue.main.async(){
                let url = js[0]["photos"].string
                let urlString = try! url?.asURL()
                _ = NSData(contentsOf: urlString!)
                var remainingApiCalls = js.count
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
                    
                    self.foodMenuArray.append(foodModel)
                    
                    remainingApiCalls = remainingApiCalls - 1
                    
                }
                if remainingApiCalls == 0{
                    self.tableView.reloadData()
//                    var cartRemainingApiCalls = self.foodMenuArray.count
//                    for i in 0..<self.foodMenuArray.count{
//                        let foodId = self.foodMenuArray[i].foodId
//                        self.cartDetailApi(r_id: rid, email: loginEmail, f_id: foodId)
//                        cartRemainingApiCalls = cartRemainingApiCalls - 1
//                    }
//                    if cartRemainingApiCalls == 0{
//                        self.tableView.reloadData()
//                    }
                    
                }
            }
        }
        
        task.resume()
    }
//    func getFood(){
//        for i in 0..<foodMenuArray.count{
//            //let foodId = foodMenuArray[i].foodId
//            //cartDetailApi(r_id: rid, email: loginEmail, f_id: foodId)
//        }
//    }
//    func cartDetailApi(r_id:Int,email:String,f_id:Int,completionHandler: @escaping(_ orderfood: NSArray) -> ()){
//
//            let parameters: [String: String] = ["r_id":"\(r_id)","f_id":"\(f_id)","email":"\(email)"]
//            let jsonUrl = "http://192.168.2.226:3002/order/cartdetails"
//            let url = URL(string: jsonUrl)
//
//            AF.request(url!,method:.post,parameters: parameters,encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).responseJSON(completionHandler: { (response) in
//
//                switch response.result {
//                case .success:
//
//                    if let json = response.data {
//                        do{
//                            let js = try JSON(data: json)
//
//                            if js["message"] != "no items !"{
//                                let order = Order()
//                                order.foodId = js[0]["f_id"].int!
//                                order.qty = js[0]["qty"].int!
//                                self.foodOrder.append(order)
//                                self.tableView.reloadData()
//                                 completionHandler(self.foodOrder as NSArray)
//                            }
//
//                        }
//                        catch{
//                            print("JSON Error")
//                        }
//
//                    }
//                case .failure(let error):
//                    print(error)
//
//                }
//
//
//            })
//
//        }
    func cartDetailApi(r_id:Int,email:String){
        
        let url = URL(string: "http://192.168.2.226:3005/order/cartdetails")
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
                            self.foodOrder.append(cart)
                            itemLabel.text = "\(totalItem)"
                            self.tableView.reloadData()
                            //self.findTotalAmount()
                        }

                }
            }
        }
        task.resume()
    }
    func findTotalAmount(){
        totalMainAmount = 0
        for i in 0..<foodOrder.count{
            totalMainAmount = totalMainAmount + foodOrder[i].total_amount
            
        }
        priceLabel.text = "\(totalMainAmount)"
    }
    
}

extension RestaurentDetailTableViewController:deleteprice{
    func delete(price: Int) {
        totalMainAmount = totalMainAmount + (price)
        priceLabel.text = "\(totalMainAmount)"
    }
}
