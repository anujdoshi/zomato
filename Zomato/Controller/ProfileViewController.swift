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
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollViewOutlet.bounces = false
        getProfileApi(email: loginEmail)
        scrollViewOutlet.contentSize.width = 1.0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    /*
    // MARK: - Logout Button Action
    */
    @IBAction func logOutButton(_ sender: UIButton) {
        userDefault.removeObject(forKey: "usersignedin")
        userDefault.removeObject(forKey: "usersignedinemail")
        userDefault.removeObject(forKey: "userauthtoken")
        userDefault.synchronize()
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Change Password Button Action
    */
    @IBAction func changePasswordButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChangePassword", sender: self)
    }
    /*
    // MARK: - Edit Profile Button Action
    */
    @IBAction func editProfileButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToEditProfile", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let editVC = segue.destination as! EditProfileViewController
        editVC.email = userEmailLabel.text!
        editVC.address = addressLabel.text!
        editVC.phoneNumber = Int(phoneNumberLabel.text!)!
        editVC.city = cityLabel.text!
        editVC.fullName = fullNameLabel.text!
    }
    /*
    // MARK: - Get API
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
        }
        task.resume()
    }
    /*
    // MARK: - Create Alert Button
    */
    func createAlert(message:String,buttonTitle:String){
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .cancel) { (UIAlertAction) in
            self.userDefault.removeObject(forKey: "usersignedin")
            self.userDefault.removeObject(forKey: "usersignedinemail")
            self.userDefault.removeObject(forKey: "userauthtoken")
            self.userDefault.synchronize()
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
