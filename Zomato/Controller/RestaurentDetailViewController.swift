//
//  RestaurentDetailViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 21/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
var restaurentId:Int = 0
var totalMainAmount = 0
var totalItem = 0
//Configure a custom view
var uiView:UIView = UIView()
let itemLabel = UILabel(frame: CGRect(x:3,y:10,width: 100,height: 30))
let priceLabel = UILabel(frame: CGRect(x: 3, y: 30, width: 90, height: 30))
let viewCart = UIButton()

class RestaurentDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    // Variable
    var myTableView: UITableView!
    var foodOrder = [Cart]()
    var foodMenuDetailsArray = [RestaurentMenuModel]()
    //Extra Variable
    var id :Int = 0
    var foodMenuArray = [RestaurentMenuModel]()
    
    private var NUMBER_OF_ROWS: Int = 0
    private let ROW_HEIGHT: CGFloat = 75.0
    private let MINIMUM_CONSTANT_VALUE: CGFloat = -150.0 /// This is the hidable view's height

    weak var hidableViewTopConstraint: NSLayoutConstraint! /// This is an outlet from your storyboard
    private var lastContentOffset: CGFloat = 0.0
    //Outlet
    //@IBOutlet var scrollView: UIScrollView!
    @IBOutlet var restaurentPhoneNumber: UILabel!
    @IBOutlet var restaurentHours: UILabel!
    @IBOutlet var restaurentName: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var restaurentAddress: UILabel!
    @IBOutlet var restaurentDetails: UILabel!
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurentId = id
        getRestaurentDetailApi(id: restaurentId)
        updateUI()
        loadingActivity()
        tableView.delegate = self
        //For Register a custom cell
        tableView.register(UINib(nibName: "RestaurentMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
   
    override func viewDidDisappear(_ animated: Bool) {
        totalMainAmount = 0
        foodOrder.removeAll()
        deletCartDetails(rid: rid, loginEmail: loginEmail)
    }
    /*
    // MARK: - Update UI
    */
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
        //getRestaurentDetailApi(id: restaurentId)
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
            getRestaurentDetailsApi(id: rid)
    }
    /*
    // MARK: - API (Restaurent Detail)
    */
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
            let js = try! JSON(data: data)
            
            DispatchQueue.main.async(){
                let url = js[0]["photos"].string
                let urlString = try! url?.asURL()
                let datas = NSData(contentsOf: urlString!)
                self.restaurentName.text = js[0]["restaurant_name"].string!
                self.restaurentHours.text = "⏰ \(js[0]["opening_hours"])"
                self.restaurentAddress.text = "🏠 Address:  \(js[0]["address"])"
                self.restaurentPhoneNumber.text = "📞\(js[0]["phone_no"])"
                self.restaurentDetails.text = "● Details: \(js[0]["cuisin_type"])"
                self.imageView.image = UIImage(data: (datas as Data?)!)
            }
        }
        
        task.resume()
        activityIndicatorView.stopAnimating()
        VW_overlay.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        NUMBER_OF_ROWS = foodMenuDetailsArray.count
        return foodMenuDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RestaurentMenuTableViewCell
        let urlString = try! foodMenuDetailsArray[indexPath.row].foodImage.asURL()
        let data = NSData(contentsOf: urlString)
        cell.foodName.text = foodMenuDetailsArray[indexPath.row].foodName
        cell.foodPrice.text = "₹\(foodMenuDetailsArray[indexPath.row].foodAmount)"
        cell.imageViewFood.image = UIImage(data: data! as Data)
        cell.steeperOutlet.tag = foodMenuDetailsArray[indexPath.row].foodId
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // MARK: - View Cart Button Action
    */
    @objc func viewCartButton(){

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToCart", sender: self)

        }
    }
    
    /*
    // MARK: - Get API
    */
    func getRestaurentDetailsApi(id:Int){
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
                    self.foodMenuDetailsArray.append(foodModel)
                    
                }
                activityIndicatorView.stopAnimating()
                VW_overlay.isHidden = true
            }
        }
        
        task.resume()
        
    }
    
    /*
    // MARK: - Delete Cart API
    */
    func deletCartDetails(rid:Int,loginEmail:String){
        let url = URL(string: "\(urlAPILocation)order/delcartdetails")
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
            let js = try! JSON(data: data)
            print(js)
        }
        task.resume()
    }
    
}
