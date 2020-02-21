//
//  RestaurantViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 20/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class RestaurantViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var restaurentArray = [RestaurentModel]()
    var timer = Timer()
    var restaurentId : Int = 0
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "RestaurantTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        getApi()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestaurantTableViewCell
        let urlString = try! restaurentArray[indexPath.row].photo.asURL()
        let data = NSData(contentsOf: urlString)
        
        cell.restaurantName.text = restaurentArray[indexPath.row].restauren_name
        cell.restaurantPhoneNumber.text = restaurentArray[indexPath.row].phonenumber
        cell.restaurantType.text = restaurentArray[indexPath.row].restaurentType
        cell.openingHours.text = restaurentArray[indexPath.row].openingHour
        cell.restaurantImage.image = UIImage(data: data as! Data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        restaurentId = restaurentArray[indexPath.row].id
        getRestaurentDetailApi(id:restaurentId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func getApi(){
        let jsonUrl = "http://192.168.2.226:3002/res/restaurents"
        let url = URL(string: jsonUrl)
        Alamofire.request(url!,method: .get).responseJSON { (response) in
            
            if response.result.isSuccess{
                let musicJSON : JSON = JSON(response.result.value!)
                self.getData(json: musicJSON)
            }else{
                print("error")
            }
        }
    }
    func getData(json:JSON){
    
        for i in 0..<json.count{
            let id = json[i]["r_id"]
            let name = json[i]["restaurant_name"]
            let type = json[i]["cuisin_type"]
            let photo = json[i]["photos"]
            let opening = json[i]["opening_hours"]
            let phoneNumber = json[i]["phone_no"]
            let model = RestaurentModel()
            model.id = id.int!
            model.restauren_name = name.string!
            model.restaurentType = type.string!
            model.photo = photo.string!
            model.openingHour = opening.string!
            model.phonenumber = phoneNumber.string!
            restaurentArray.append(model)
            self.tableView.reloadData()
        }
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

            let responseString = String(data: data, encoding: .utf8)
            if responseString != nil{
                DispatchQueue.main.async(){
                    self.performSegue(withIdentifier: "goToDetails", sender: self)
                }
                
            }
            else{
                
            }
        }

        task.resume()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let barVC = segue.destination as? UITabBarController {
            barVC.viewControllers?.forEach {
                if let vc = $0 as? RestaurentDetailViewController {
                    vc.id = self.restaurentId
                }
            }
        }
        
    }
}
