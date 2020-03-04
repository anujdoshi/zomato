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
    //Extra Variable
    var id :Int = 0
    var foodMenuArray = [RestaurentMenuModel]()
    //Outlet
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
        loadingActivity()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+100)
        scrollView.contentSize.width = 1.0
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
            getRestaurentDetailApi(id: rid)
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
                self.restaurentHours.text = "⏰ Opening Hours:\(js[0]["opening_hours"])"
                self.restaurentAddress.text = "🏠 Address:  \(js[0]["address"])"
                self.restaurentPhoneNumber.text = "📞 Phone Number: \(js[0]["phone_no"])"
                self.restaurentDetails.text = "● Details: \(js[0]["cuisin_type"])"
                self.imageView.image = UIImage(data: (datas as Data?)!)
            }
        }
        
        task.resume()
        activityIndicatorView.stopAnimating()
        VW_overlay.isHidden = true
    }
}
