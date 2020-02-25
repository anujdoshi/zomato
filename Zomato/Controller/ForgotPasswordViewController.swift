//
//  ForgotPasswordViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 25/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import SwiftyJSON
class ForgotPasswordViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet var resetPasswordButtonOultlet: UIButton!
    @IBOutlet var passwordLabel: UITextField!
    @IBOutlet var emailLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        changePasswordApi()
    }
    func updateUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        passwordLabel.isHidden = true
        resetPasswordButtonOultlet.isHidden = true
        emailLabel.layer.cornerRadius = 15.0
        emailLabel.layer.borderWidth = 1.0
        emailLabel.layer.borderColor = gray.cgColor
        
        passwordLabel.layer.cornerRadius = 15.0
        passwordLabel.layer.borderWidth = 1.0
        passwordLabel.layer.borderColor = gray.cgColor
        
        resetPasswordButtonOultlet.layer.cornerRadius = 15.0
        resetPasswordButtonOultlet.layer.borderWidth = 1.0
        resetPasswordButtonOultlet.layer.borderColor = gray.cgColor
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailLabel.resignFirstResponder()
        verifyEmailApi()
        passwordLabel.resignFirstResponder()
        
    }
    
    
    
    func verifyEmailApi(){
        let email = emailLabel.text
        let url = URL(string: "http://192.168.2.226:3002/users/forgotpass")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!]
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
            if json["message"] == "Verified"{
                DispatchQueue.main.async(){
                    self.passwordLabel.isHidden = false
                    self.resetPasswordButtonOultlet.isHidden = false
                }
            }else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "This email \(String(describing: email)) is not in our database please verify or register.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
        }

        task.resume()
    }
    func changePasswordApi(){
        let email = emailLabel.text
        let password = passwordLabel.text
        let url = URL(string: "http://192.168.2.226:3002/users/changepass")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!,"password":password!]
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
            if json["message"] == "Password Changed"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "Password Successfully changed!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                        //
                        self.performSegue(withIdentifier: "goToVerifiedLogin", sender: self)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "This email \(String(describing: email)) is not in our database please verify or register.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
        }

        task.resume()
    }
}
