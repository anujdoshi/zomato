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
class RestaurentDetailViewController: UIViewController {
    
    var id :Int = 0
    var foodMenuArray = [RestaurentMenuModel]()
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var restaurentPhoneNumber: UILabel!
    @IBOutlet var restaurentHours: UILabel!
    @IBOutlet var restaurentName: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var restaurentAddress: UILabel!
    
    @IBOutlet var restaurentDetails: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurentId = id
        getRestaurentDetailApi(id: rid)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+100)
        scrollView.contentSize.width = 1.0
    }
    
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
                let datas = NSData(contentsOf: urlString!)
                self.restaurentName.text = js[0]["restaurant_name"].string!
                self.restaurentHours.text = "Opening Hours:  \(js[0]["opening_hours"])"
                self.restaurentAddress.text = "Address:  \(js[0]["address"])"
                self.restaurentPhoneNumber.text = "Phone Number: \(js[0]["phone_no"])"
                self.restaurentDetails.text = "Details: \(js[0]["cuisin_type"])"
                self.imageView.image = UIImage(data: (datas as Data?)!)
            }
        }
        
        task.resume()
        activityIndicatorView.stopAnimating()
        VW_overlay.isHidden = true
    }
}
