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
    var paymentMethod:String = ""
    let placeOrder = UIButton()
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.myTableView.register(UINib(nibName: "AddToCartDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.myTableView.dataSource = self
        self.myTableView.delegate = self
        
    }
    
    func updateUI(){
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: myTableView.frame.width, height: 70))
        placeOrder.frame = CGRect(x: view.bounds.maxX-200, y: 0, width: 200, height: 100)
        uiview.backgroundColor = Color.red
        uiview.translatesAutoresizingMaskIntoConstraints = false
        placeOrder.setTitleColor(UIColor.white, for: .normal)
        placeOrder.setTitle("View Cart", for: .normal)
        placeOrder.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        placeOrder.autoresizingMask = [.flexibleLeftMargin,.flexibleBottomMargin]
        myTableView.tableFooterView = uiview
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! AddToCartDetailsTableViewCell
//        cell.foodName.text = "\(foodOrder[indexPath.row].foodName)"
//        cell.qtyLabel.text = "\(foodOrder[indexPath.row].qty)"
//        cell.priceLabel.text = "\(foodOrder[indexPath.row].amount)"
        return cell
    }
    
    func didSelectButton(selectedButton: UIButton?) {
        //
        
        print(selectedButton as Any)
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
    override func viewDidDisappear(_ animated: Bool) {
        //foodOrder.removeAll()
    }
}
