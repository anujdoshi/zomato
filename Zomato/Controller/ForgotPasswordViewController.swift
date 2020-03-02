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

    @IBOutlet var fourthOtpTextField: UITextField!
    @IBOutlet var thirdOtpTextField: UITextField!
    @IBOutlet var secondOtpTextField: UITextField!
    @IBOutlet var firstOtpTextField: UITextField!
    @IBOutlet var resetPasswordButtonOultlet: UIButton!
    @IBOutlet var passwordLabel: UITextField!
    @IBOutlet var emailLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        delegateTextField()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func resetPasswordButton(_ sender: UIButton) {
        changePasswordApi()
    }
    func delegateTextField(){
        firstOtpTextField.delegate = self
        secondOtpTextField.delegate = self
        thirdOtpTextField.delegate = self
        fourthOtpTextField.delegate = self
    }
    func updateUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        firstOtpTextField.isHidden = true
        secondOtpTextField.isHidden = true
        thirdOtpTextField.isHidden = true
        fourthOtpTextField.isHidden = true
        
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
        let url = URL(string: "http://192.168.2.226:3000/users/forgotpass")
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
            if json["message"] == "Verified !! OTP sent in Mail"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "Otp is sent to this email address \(email ?? "0").", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .cancel) { (UIAlertAction) in
                        self.emailLabel.isHidden = true
                        self.firstOtpTextField.isHidden = false
                        self.secondOtpTextField.isHidden = false
                        self.thirdOtpTextField.isHidden = false
                        self.fourthOtpTextField.isHidden = false
                        self.firstOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.secondOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.thirdOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                        self.fourthOtpTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            }else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "This email \(email ?? "0") is not in our database please check agian or register.", preferredStyle: .alert)
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
        let url = URL(string: "http://192.168.2.226:3000/users/changepass")
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
    @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        if (text?.utf16.count)! >= 1{
            switch textField{
            case firstOtpTextField:
                secondOtpTextField.becomeFirstResponder()
            case secondOtpTextField:
                thirdOtpTextField.becomeFirstResponder()
            case thirdOtpTextField:
                fourthOtpTextField.becomeFirstResponder()
            case fourthOtpTextField:
                fourthOtpTextField.resignFirstResponder()
                verifyOTP()
            default:
                break
            }
        }else{

        }
    }
    func verifyOTP(){
        let otp = "\(firstOtpTextField.text ?? "")"+"\(secondOtpTextField.text ?? "")"+"\(thirdOtpTextField.text ?? "")"+"\(fourthOtpTextField.text ?? "")"
        let email = emailLabel.text
        let url = URL(string: "http://192.168.2.226:3000/users/verifyotp")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!,"otp":otp]
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
            if json["message"] == "OTP Verified"{
                DispatchQueue.main.async(){
                    self.emailLabel.isHidden = true
                    self.firstOtpTextField.isHidden = true
                    self.secondOtpTextField.isHidden = true
                    self.thirdOtpTextField.isHidden = true
                    self.fourthOtpTextField.isHidden = true
                    self.passwordLabel.isHidden = false
                    self.resetPasswordButtonOultlet.isHidden = false
                    
                }
            }else if json["message"] == "Wrong OTP"{
                DispatchQueue.main.async(){
                    let alert = UIAlertController(title: "Forgot Password", message: "OTP is wrong", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
        }

        task.resume()
    }
}

