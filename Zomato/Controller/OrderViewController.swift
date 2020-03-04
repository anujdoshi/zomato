//
//  OrderViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 02/03/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class OrderViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var orderArray = [UserOrder]()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        orderArray.removeAll()
        loadingActivity()
        
    }
    /*
    // MARK: - Table View Method
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderTableViewCell
        
        if let url = URL(string: orderArray[indexPath.row].restaurentImage){
            do{
                let data = try Data(contentsOf: url)
                cell.restaurentImage.image = UIImage(data: data)
            }catch{
                
            }
        }
        cell.restaurentName.text = orderArray[indexPath.row].restaurentName
        cell.foodOrderDetails.text = "\(orderArray[indexPath.row].qty)=>\(orderArray[indexPath.row].foodName)"
        cell.totalAmount.text = "\(orderArray[indexPath.row].total_amount)"
        cell.foodOrderOn.text = orderArray[indexPath.row].date_time
        return cell
    }
    /*
    // MARK: - Loader Implementation Function
    */
    func loadingActivity(){
            VW_overlay = UIView(frame: UIScreen.main.bounds)
            VW_overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

            activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.frame = CGRect(x: 0, y: 0, width: activityIndicatorView.bounds.size.width, height: activityIndicatorView.bounds.size.height)
            activityIndicatorView.color = UIColor.red
            activityIndicatorView.center = VW_overlay.center

            
            VW_overlay.addSubview(activityIndicatorView)
            VW_overlay.center = view.center
        
            view.addSubview(VW_overlay)
            activityIndicatorView.startAnimating()
            perform(#selector(self.getRestaurentDetail), with: activityIndicatorView, afterDelay: 0.01)

    }
    @objc func getRestaurentDetail(){
            getRestaurentDetailApi()
    }
    /*
    // MARK: - Get API
    */
    func getRestaurentDetailApi(){
        let url = URL(string: "\(urlAPILocation)orderlist/getorderdetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":loginEmail]
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
            if js["message"] != "No Orders in OrderList"{
                DispatchQueue.main.async(){
                    
                    for i in 0..<js.count{
                        let foodId = js[i]["f_id"]
                        let restaurentId = js[i]["r_id"]
                        let qty = js[i]["qty"]
                        let address = js[i]["address"]
                        let payment_type = js[i]["payment_type"]
                        let date_time = js[i]["date_time"]
                        let totalamount = js[i]["total_amount"]
                        let orderModel = UserOrder()
                        orderModel.f_id = foodId.int!
                        orderModel.r_id = restaurentId.int!
                        orderModel.address = address.string!
                        orderModel.payment_type = payment_type.string!
                        orderModel.qty = qty.int!
                        orderModel.date_time = date_time.string!
                        orderModel.total_amount = totalamount.int!
                        self.orderArray.append(orderModel)
                        self.getRestaurentDetailApi(id: restaurentId.int!, oid: i)
                        self.getFoodDetails(id: foodId.int!, oid: i)
                        self.tableView.reloadData()
                        
                    }
                    activityIndicatorView.stopAnimating()
                    VW_overlay.isHidden = true
                }
            }else{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Order", message: "You have no order in order list", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    activityIndicatorView.stopAnimating()
                    VW_overlay.isHidden = true
                }
            }
            
        }
        task.resume()
    }
    func getRestaurentDetailApi(id:Int,oid:Int){
        let url = URL(string: "\(urlAPILocation)res/restaurents/resdetail")
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
                self.orderArray[oid].restaurentName = js[0]["restaurant_name"].string!
                self.orderArray[oid].restaurentImage = js[0]["photos"].string!
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    func getFoodDetails(id:Int,oid:Int){
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
            
            
            DispatchQueue.main.async(){
                self.orderArray[oid].foodName = json[0]["food_name"].string!
                self.tableView.reloadData()
            }
        }
        
        task.resume()
        
    }
}
