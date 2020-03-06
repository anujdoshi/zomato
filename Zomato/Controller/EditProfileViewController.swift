//
//  EditProfileViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 05/03/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class EditProfileViewController: UIViewController {
    
    //Outlet's
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var addressTextView: UITextView!
    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var fullNameTextField: UITextField!
    var email:String = ""
    var phoneNumber:Int = 0
    var address:String = ""
    var city:String = ""
    var fullName:String = ""
    /*
    // MARK: - View Override Methods
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = email
        phoneNumberTextField.text = String(phoneNumber)
        addressTextView.text = address
        cityTextField.text = city
        fullNameTextField.text = fullName
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    /*
    // MARK: - Edit Profile Button
    */
    @IBAction func editProfileButton(_ sender: UIButton) {
        if emailLabel.text == "" || addressTextView.text == "" || cityTextField.text == "" || phoneNumberTextField.text == "" || fullNameTextField.text == ""{
            let alert = UIAlertController(title: "Edit Profile", message: "All field are necassory so it can't be empty!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }else{
            editProfileApi()
        }
        
    }
    /*
    // MARK: - Edit Profile API
    */
    func editProfileApi(){
        let email = emailLabel.text
        let username = fullNameTextField.text
        let phone = phoneNumberTextField.text
        let address = addressTextView.text
        let city = cityTextField.text
        
        
        let url = URL(string: "\(urlAPILocation)users/editprofile")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.headers = header
        let parameters: [String: String] = ["email":"\(email ?? "")","username":"\(username ?? "0")","mob_no":"\(phone ?? "0")","city":"\(city ?? "0")","address":"\(address ?? "0")"]
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
            print(js)
            if js["message"] == "Wrong Auth Token"{
                
            }else if js["message"] == "Profile Updated"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Edit Profile", message: "Profile Edited Successfully", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }else{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Edit Profile", message: "Something Went wrong Try again!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        task.resume()
    }
}
