//
//  RegisterViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 20/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,UIScrollViewDelegate {
    var validation = Validation()
    var timer = Timer()
    var validate = false
    var counter = 0
    var imgArr = [UIImage(named: "food"),UIImage(named: "food1"),UIImage(named: "food2"),UIImage(named: "food3"),UIImage(named: "food4"),UIImage(named: "food5")]
    
    //Extra View Outlet's
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    //TextField Outlet's
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //Button Outlet
    @IBOutlet weak var registerButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButtonOutlet.isUserInteractionEnabled = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        nameTextField.delegate = self
        addressTextField.delegate = self
        phoneNumberTextField.delegate = self
        cityTextField.delegate = self
        
        scrollViewOutlet.delegate = self
        //For update TextfieldUI
        updateTextFieldUI()
        
        // For Disable Keyboard when touch outside the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //For change the image every second
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollViewOutlet.bounces = false
        scrollViewOutlet.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+100)
        scrollViewOutlet.contentSize.width = 1.0
    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        cityTextField.resignFirstResponder()
        addressTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    func updateTextFieldUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        emailTextField.layer.cornerRadius = 15.0
        emailTextField.layer.borderWidth = 1.0
        emailTextField.layer.borderColor = gray.cgColor
        
        passwordTextField.layer.cornerRadius = 15.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = gray.cgColor
        
        nameTextField.layer.cornerRadius = 15.0
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.borderColor = gray.cgColor
        
        phoneNumberTextField.layer.cornerRadius = 15.0
        phoneNumberTextField.layer.borderWidth = 1.0
        phoneNumberTextField.layer.borderColor = gray.cgColor
        
        addressTextField.layer.cornerRadius = 15.0
        addressTextField.layer.borderWidth = 1.0
        addressTextField.layer.borderColor = gray.cgColor
        
        cityTextField.layer.cornerRadius = 15.0
        cityTextField.layer.borderWidth = 1.0
        cityTextField.layer.borderColor = gray.cgColor
        
        registerButtonOutlet.layer.cornerRadius = 15.0
        registerButtonOutlet.layer.borderWidth = 1.0
        registerButtonOutlet.layer.borderColor = gray.cgColor
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        validateTextField()
        return true
    }
    
    @objc func changeImage() {
    
        if counter < imgArr.count {
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            counter += 1
        } else {
            counter = 0
            let index = IndexPath.init(item: counter, section: 0)
            self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            counter = 1
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let vc = cell.viewWithTag(1) as? UIImageView {
            vc.image = imgArr[indexPath.row]
        }
        return cell
    }
    
    @IBAction func registerButtonPress(_ sender: UIButton) {
        if validate == true{
            getApi()
        }else{
            let alert = UIAlertController(title: "Register", message: "Please Provide all details correctly", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    func validateTextField(){
            guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text,
                let phone = phoneNumberTextField.text else {
                    return
            }
            let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
            let isValidateName = self.validation.validateName(name: name)
            if (isValidateName == false) {
                highlightTextField(textfield: nameTextField,color: UIColor.red)
                  return
            }else{
                highlightTextField(textfield: nameTextField,color: gray)
            }
            let isValidateEmail = self.validation.validateEmailId(emailID: email)
            if (isValidateEmail == false) {
                highlightTextField(textfield: emailTextField,color: UIColor.red)
                return
            }else{
                let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
                highlightTextField(textfield: emailTextField,color: gray)
            }
//            let isValidatePass = self.validation.validatePassword(password: password)
//            if (isValidatePass == false) {
//                highlightTextField(textfield: passwordTextField,color: UIColor.red)
//                let alert = UIAlertController(title: "Register", message: "Password should contains 8 characters and at least 1 Alphabet and 1 Number", preferredStyle: .alert)
//                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//                alert.addAction(action)
//                return
//            }else{
//                highlightTextField(textfield: passwordTextField,color: gray)
//            }
//            let isValidatePhone = self.validation.validaPhoneNumber(phoneNumber: phone)
//            if (isValidatePhone == false) {
//                highlightTextField(textfield: phoneNumberTextField,color: UIColor.red)
//                return
//            }else{
//                highlightTextField(textfield: phoneNumberTextField,color: gray)
//            }
            if (isValidateName == true || isValidateEmail == true ) {
                validate = true
            }
    }
    func highlightTextField(textfield:UITextField,color:UIColor){
        textfield.layer.borderColor = color.cgColor
    }
    func getApi(){
        let email = emailTextField.text
        let username = nameTextField.text
        let phone = phoneNumberTextField.text
        let address = addressTextField.text
        let city = cityTextField.text
        let password = passwordTextField.text
        let url = URL(string: "http://192.168.2.226:3002/users/register")
        var request = URLRequest(url: url!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["email":email!,"password":password!,"username":username!,"mob_no":phone!,"city":city!,"address":address!]
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

            let responseString = String(data: data, encoding: .utf8)
            //print("responseString = \(responseString ?? "")")
            print(responseString as Any)
            if responseString == "Success"{
                
            }
            else{
                let alert = UIAlertController(title: "Register", message: "Something is wrong. Try Again!!!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }

        task.resume()
    }
}
extension RegisterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
extension Dictionary {
    func percentEncodeds() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAlloweds: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
