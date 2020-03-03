//
//  ProfileViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 24/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileViewController: UIViewController {
    let userDefault = UserDefaults.standard
    
    // Outlet's
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet var userEmailLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var logoutOutlet: UIButton!
    
    /*
    // MARK: - View's Override Function
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutOutlet.isUserInteractionEnabled = true
        getProfileApi(email: loginEmail)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollViewOutlet.bounces = false

        scrollViewOutlet.contentSize.width = 1.0
    }
    
    /*
    // MARK: - Logout Button Action
    */
    @IBAction func logOutButton(_ sender: UIButton) {
        userDefault.removeObject(forKey: "usersignedin")
        userDefault.synchronize()
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Get API
    */
    func getProfileApi(email:String){
        let url = URL(string: "\(urlAPILocation)users/profiledetails")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email]
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
                
                for i in 0..<js.count{
                    let userName = js[i]["username"]
                    let email = js[i]["email"]
                    let mob_no = js[i]["mob_no"]
                    let address = js[i]["address"]
                    let city = js[i]["city"]
                    self.fullNameLabel.text = userName.string!
                    self.addressLabel.text = address.string!
                    self.phoneNumberLabel.text = mob_no.string!
                    self.cityLabel.text = city.string!
                    self.userEmailLabel.text = email.string!
                    
                }
            }
        }
        task.resume()
    }
}
