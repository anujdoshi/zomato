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
import GeometricLoaders
import SkeletonView
import MaterialComponents.MaterialActivityIndicator
var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()

var VW_overlay: UIView = UIView()
var rid:Int = 0
class RestaurantViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    var container: CircleLoader?
    
    //Searchbar outlet
    @IBOutlet var searchBar: UISearchBar!
   
    var timer = Timer()
    var restaurentId : Int = 0
    var restaurentArray = [RestaurentModel]()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        tableView.register(UINib(nibName: "RestaurantTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        loadingActivity()
    }
    override func viewDidLayoutSubviews() {
        view.layoutSkeletonIfNeeded()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    /*
    // MARK: - Loader Implementation Function
    */
    func loadingActivity(){
            VW_overlay = UIView(frame: UIScreen.main.bounds)
            VW_overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

            activityIndicatorView.sizeToFit()
            
            activityIndicatorView.frame = CGRect(x: 0, y: 0, width: activityIndicatorView.bounds.size.width, height: activityIndicatorView.bounds.size.height)
            activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.center = VW_overlay.center
            VW_overlay.addSubview(activityIndicatorView)
            VW_overlay.center = view.center
            activityIndicatorView.color = UIColor.red
            view.addSubview(VW_overlay)
            activityIndicatorView.startAnimating()
            
            perform(#selector(self.getApi), with: activityIndicatorView, afterDelay: 0.01)

    }
    /*
    // MARK: - Table View Methods
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestaurantTableViewCell
        let urlString = try! restaurentArray[indexPath.row].photo.asURL()
        let data = NSData(contentsOf: urlString)
        cell.restaurantName.text = restaurentArray[indexPath.row].restauren_name
        //cell.restaurantPhoneNumber.text = restaurentArray[indexPath.row].phonenumber
        cell.restaurantType.text = restaurentArray[indexPath.row].restaurentType
        cell.openingHours.text = "⏰\(restaurentArray[indexPath.row].openingHour)"
        cell.restaurantImage.image = UIImage(data: data! as Data)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rid = restaurentArray[indexPath.row].id
        restaurentId = restaurentArray[indexPath.row].id
        getRestaurentDetailApi(id:restaurentId)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // MARK: - API Function
    */
    @objc func getApi(){
        let jsonUrl = "\(urlAPILocation)res/restaurents"
        let url = URL(string: jsonUrl)
        AF.request(url!,method:.get).responseJSON(completionHandler: { (response) in
            let json : JSON = JSON(response.value!)
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
                self.restaurentArray.append(model)
                self.tableView.reloadData()
            }
            activityIndicatorView.stopAnimating()
            VW_overlay.isHidden = true
        })
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
    /*
    // MARK: - Prepare Segue
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let barVC = segue.destination as? UITabBarController {
            barVC.viewControllers?.forEach {
                if let vc = $0 as? RestaurentDetailViewController {
                    vc.id = self.restaurentId
                }
            }
        }
        
    }
    /*
    // MARK: - Search Bar Delegate Method (textDidChange)
    */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
        if (searchBar.text?.count)! > 2 {
            getSearchRestaurentDetailApi(food_name: searchText)
        }
        
    }
    /*
    // MARK: - Search API (Restaurent Detail)
    */
    func getSearchRestaurentDetailApi(food_name:String){
        restaurentArray.removeAll()
        tableView.reloadData()
        
        let url = URL(string: "\(urlAPILocation)food/search")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["food_name":food_name]
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
                self.getData(json: js)
            }
        }

        task.resume()
    }
    /*
    // MARK: - Search Bar Cancel Button Clicked
    */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        restaurentArray.removeAll()
        tableView.reloadData()
        searchBar.showsCancelButton = true
        getApi()
    }
}
