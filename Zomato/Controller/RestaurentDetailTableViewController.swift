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
class RestaurentDetailTableViewController: UITableViewController {
    var foodId = 0
    var qty = 0
    var foodMenuArray = [RestaurentMenuModel]()
    var foodOrder = [Order]()
    //@IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "RestaurentMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        getRestaurentDetailApi(id: restaurentId)
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
        cell.imageViewFood.image = UIImage(data: data as! Data)
        cell.stepperOutlet.tag = foodMenuArray[indexPath.row].foodId
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func getRestaurentDetailApi(id:Int){
        let url = URL(string: "http://192.168.2.226:3002/res/restaurents/resdetail")
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
                let datas = NSData(contentsOf: urlString!)
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
                    self.tableView.reloadData()
                }
            }
        }

        task.resume()
    }
//    func cartDetailApi(r_id:Int,email:String,f_id:Int)->[Int]{
//
//        var qty = 0
//        let url = URL(string: "http://192.168.2.226:3002/order/cartdetails")
//        var request = URLRequest(url: url!)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        let parameters: [String: Any] = ["r_id":r_id,"email":email,"f_id":f_id]
//
//        request.httpBody = parameters.percentEncoded()
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,
//                let response = response as? HTTPURLResponse,
//                error == nil else {
//                print("error", error ?? "Unknown error")
//                return
//            }
//
//            guard (200 ... 299) ~= response.statusCode else {
//                print("statusCode should be 2xx, but is \(response.statusCode)")
//                print("response = \(response)")
//                return
//            }
//            do{
//                let js = try JSON(data: data)
//                print(js)
//                if js.count > 0{
//                    let order = Order()
//                    order.foodId = js[0]["f_id"].int!
//                    order.qty = js[0]["qty"].int!
//                    self.foodId = js[0]["f_id"].int!
//                    qty = js[0]["qty"].int!
//                    print(self.foodId)
//                    self.foodOrder.append(order)
//                }
//            }catch{
//                print("error")
//            }
//
//            }
//        task.resume()
//        return [self.foodId,qty]
//    }
    func cartDetailApi(r_id:Int,email:String,f_id:Int)->[Int]{
        let addTocart = addToCart(f_id: f_id, r_id: r_id, email: loginEmail)
        //let parameters: [String: String] = ["r_id":"\(r_id)","email":"\(email)","f_id":"\(f_id)"]
        let jsonUrl = "http://192.168.2.226:3002/order/cartdetails"
        let url = URL(string: jsonUrl)
        AF.request(url!,method:.post,parameters: addTocart,encoder: URLEncodedFormParameterEncoder(destination: .httpBody)).responseJSON(completionHandler: { (response) in
            
            let js : JSON = JSON(response)
            
            print(js)
            //self.foodId = js[0]["f_id"].int!
            //self.qty = js[0]["qty"].int!
            //print(self.foodId)
            
            
        })
        return [1,2]
    }
}
