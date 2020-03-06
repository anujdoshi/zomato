//
//  PlaceOrderDetailsViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 02/03/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class PlaceOrderDetailsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,SSRadioButtonControllerDelegate {
    var addressTextField = UITextField()
    var paymentMethod:String = ""
    let placeOrder = UIButton()
    var foodOrder = [Cart]()
    var radioButtonController: SSRadioButtonsController?
    @IBOutlet var onlinePaymentButton: SSRadioButton!
    @IBOutlet var cashButton: SSRadioButton!
    @IBOutlet var myTableView: UITableView!
    @IBOutlet var addressLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        foodOrder.removeAll()
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.myTableView.register(UINib(nibName: "AddToCartDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        cartDetailApi(r_id: rid, email: loginEmail)
        radioButtonController = SSRadioButtonsController(buttons: cashButton, onlinePaymentButton)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismisView))
        self.view.addGestureRecognizer(tapGesture)
        getProfileApi(email: loginEmail)
        updateUI()
    }
    @objc func dismisView(){
        foodOrder.removeAll()
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Update UI
    */
    func updateUI(){
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 50))
        placeOrder.frame = CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 50)
        uiview.backgroundColor = Color.red
        uiview.translatesAutoresizingMaskIntoConstraints = false
        placeOrder.setTitleColor(UIColor.white, for: .normal)
        placeOrder.setTitle("Place Order", for: .normal)
        placeOrder.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        placeOrder.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
        placeOrder.addTarget(self, action: #selector(self.placeOrderButton), for: .touchUpInside)
        myTableView.tableFooterView = uiview
        uiview.addSubview(placeOrder)
        uiview.isHidden = false
    }
    /*
    // MARK: - Tableview Methods
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return foodOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! AddToCartDetailsTableViewCell
        cell.foodName.text = "\(foodOrder[indexPath.row].foodName)"
        cell.qtyLabel.text = "\(foodOrder[indexPath.row].qty)"
        cell.priceLabel.text = "\(foodOrder[indexPath.row].amount)"
        return cell
    }
    /*
    // MARK: - Radio Button Function
    */
    func didSelectButton(selectedButton: UIButton?) {
        //
        //NSLog(" \(String(describing: selectedButton))" )
        
    }
    /*
    // MARK: - API
    */
    func placeOrder(f_id:Int,qty:Int){
        let url = URL(string: "\(urlAPILocation)orderlist/addtoorderlist")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.headers = header
        let parameters: [String: Any] = ["r_id":rid,"f_id":f_id,"email":loginEmail,"qty":qty,"address":addressLabel.text!,"payment_type":paymentMethod,"total_amount":totalMainAmount]
        request.httpBody = parameters.percentEncoded()
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
            let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Server", message: "Could't connect to server please try again after some times", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                                exit(0)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            
            
                if json["message"] == "Wrong Auth Token"{
                    DispatchQueue.main.async(){
                        self.createAlert(message: "Wrong Authentication please login agian", buttonTitle: "Ok")
                    }
                }
                else if json["message"] == "Order added to Order List"{
                    DispatchQueue.main.async(){
                        let alert = UIAlertController(title: "Place Order", message: "Your Order successfully placed.Our Caption sortly order your food at your place. Thank You for chossing us", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler:nil)
                        let cancelOrder = UIAlertAction(title: "Cancel Order", style: .cancel) { (UIAlertAction) in
                            //
                        }
                        totalMainAmount = 0
                        uiView.isHidden = true
                        alert.addAction(action)
                        alert.addAction(cancelOrder)
                        
                        self.present(alert, animated: true, completion: nil)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else{
                    DispatchQueue.main.async(){
                        let alert = UIAlertController(title: "Place Order", message: "Something went wrong please try again!!!", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .cancel, handler:nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        }
        task.resume()
    }
    func cartDetailApi(r_id:Int,email:String){
        
        let url = URL(string: "\(urlAPILocation)order/cartdetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.headers = header
        let parameters: [String: Any] = ["r_id":r_id,"email":email]
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Server", message: "Could't connect to server please try again after some times", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                                exit(0)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let js = try! JSON(data: data)
            if js["message"] == "Wrong Auth Token"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "Wrong Authentication please login agian", buttonTitle: "Ok")
                }
            }else{
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
            
        }
        task.resume()
    }
    
    func getFoodDetails(id:Int){
        let url = URL(string: "\(urlAPILocation)food/fooddetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.headers = header
        let parameters: [String: Any] = ["f_id":id]
        request.httpBody = parameters.percentEncoded()
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
            let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Server", message: "Could't connect to server please try again after some times", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                                exit(0)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let json = try! JSON(data: data)
            if json["message"] == "Wrong Auth Token"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "Wrong Authentication please login agian", buttonTitle: "Ok")
                }
            }else{
                DispatchQueue.main.async(){
                     for i in 0..<self.foodOrder.count{
                         if self.foodOrder[i].foodId == id{
                             self.foodOrder[i].foodName = json[0]["food_name"].string!
                             self.myTableView.reloadData()
                         }
                     }
                }
            }
            
        }
        task.resume()
    }
    /*
    // MARK: - Get Profile API
    */
    func getProfileApi(email:String){
        let url = URL(string: "\(urlAPILocation)users/profiledetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.headers = header
        let parameters: [String: Any] = ["email":email]
        request.httpBody = parameters.percentEncoded()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Server", message: "Could't connect to server please try again after some times", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                                exit(0)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            let js = try! JSON(data: data)
            if js["message"] == "Wrong Auth Token"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "Wrong Authentication please login agian", buttonTitle: "Ok")
                }
            }else{
                DispatchQueue.main.async(){
                    for i in 0..<js.count{
                        let address = js[i]["address"]
                        self.addressLabel.text = address.string!
                    }
                }
            }
        }
        task.resume()
    }
    /*
    // MARK: - Place Order Button Action
    */
    @objc func placeOrderButton(){
        if paymentMethod == ""{
            let alert = UIAlertController(title: "Alert", message: "Please select one payment method.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else {
            DispatchQueue.main.async {
                for i in 0..<self.foodOrder.count{
                    let foodid = self.foodOrder[i].foodId
                    let qty = self.foodOrder[i].qty
                    self.placeOrder(f_id: foodid, qty: qty)
                }
            }
        }
    }
    /*
    // MARK: - Online Payment Button Action
    */
    @IBAction func onlinePaymentButton(_ sender: Any) {
        paymentMethod = "Online Payment"
    }
    /*
    // MARK: - Cash button action
    */
    @IBAction func cashButton(_ sender: SSRadioButton) {
        paymentMethod = "Cash"
    }
    /*
    // MARK: - Change Address Button Action
    */
    @IBAction func changeAddressButton(_ sender: Any) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Change Address", message: "", preferredStyle: .alert)
            let addAddress = UIAlertAction(title: "Add Address", style: .default) { (UIAlertAction) in
                //
                self.addressLabel.text = self.addressTextField.text
                
            }
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (UITextField) in
                UITextField.placeholder = "Enter Address"
                self.addressTextField = UITextField
            }
            alert.addAction(addAddress)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Create Alert Button
    */
    func createAlert(message:String,buttonTitle:String){
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .cancel) { (UIAlertAction) in
            userDefault.removeObject(forKey: "usersignedin")
            userDefault.removeObject(forKey: "usersignedinemail")
            userDefault.removeObject(forKey: "userauthtoken")
            userDefault.synchronize()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
