//
//  SegmentViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 19/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
let urlAPILocation = "http://192.168.2.226:3000/"
class SegmentViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate{
    /*
    // MARK: - TextField's Outlet
    */
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    /*
    // MARK: - Button's Outlet
    */
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet var forgotPasswordButtonOutlet: UIButton!
    
    /*
    // MARK: - View's Outlet
    */
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet var containerView: UIView!
    /*
    // MARK: - Extra Variable
    */
    let userDefaullt = UserDefaults.standard
    var timer = Timer()
    var counter = 0
    var imgArr = [UIImage(named: "food"),UIImage(named: "food1"),UIImage(named: "food2"),UIImage(named: "food3"),UIImage(named: "food4"),UIImage(named: "food5")]
    /*
    // MARK: - View's Override Function
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        //This Function will update UI
        updateUI()
        
        loginButtonOutlet.isUserInteractionEnabled = true
        forgotPasswordButtonOutlet.isUserInteractionEnabled = true
        //Textfield Delegate method is used
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // For Disable Keyboard when touch outside the view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //For change the image every second
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }

    }
    /*
    // MARK: - For Dismiss Keyboard
    */
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        if userDefaullt.bool(forKey: "usersignedin"){
            performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
        }
        scrollViewOutlet.bounces = false
        scrollViewOutlet.contentSize.width = 1.0
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
    /*
    // MARK: - Get API
    */
    func getApi(){
        let email = emailTextField.text
        let password = passwordTextField.text
        let url = URL(string: "\(urlAPILocation)users/login")
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
            print(json)
            if json["message"] == "User Logged succesfully"{
                DispatchQueue.main.async(){
                    loginEmail = self.emailTextField.text!
                    self.userDefaullt.set(true, forKey: "usersignedin")
                    self.userDefaullt.synchronize()
                    self.userDefaullt.set(email, forKey: "usersignedinemail")
                    self.performSegue(withIdentifier: "goToHomeFromLogin", sender: self)
                }
            }
            else if json["message"] == "Incoorect password or Email" {
                DispatchQueue.main.async(){
                    self.createAlert(message: "Incorect Email or Password Please Try Agian!!!", buttonTitle: "Ok")
                    
                }
                
            }
            else if json["message"] == "Email does not exits"{
                DispatchQueue.main.async(){
                    self.createAlert(message: "Please register first.Because this email \(email ?? "") is not saved in our database.", buttonTitle: "Ok")
                }
            }
        }

        task.resume()
    }
    /*
    // MARK: - Collection View methods
    */
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
    /*
    // MARK: - Login Button Action
    */
    @IBAction func loginButtonPress(_ sender: UIButton) {
        if emailTextField.text == ""{
            
            createAlert(message: "Email can't be empty", buttonTitle: "Ok")
            
        }else if passwordTextField.text == ""{
            createAlert(message: "Password can't be empty", buttonTitle: "Ok")
        }else{
            getApi()
        }
       
    }
    /*
    // MARK: - Create Alert Button
    */
    func createAlert(message:String,buttonTitle:String){
        let alert = UIAlertController(title: "Login", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    /*
    // MARK: - Forgot Password Button Action
    */
    @IBAction func forgotPasswordButton(_ sender: UIButton) {
        performSegue(withIdentifier: "goToForgotPasssword", sender: self)
    }
    /*
    // MARK: - Register Button Action
    */
    @IBAction func registerButton(_ sender: UIButton) {
        
    }
    /*
    // MARK: - Update UI Function
    */
    func updateUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        
//        emailTextField.layer.cornerRadius = 15.0
//        emailTextField.layer.borderWidth = 1.0
//        emailTextField.layer.borderColor = gray.cgColor
//        
//        passwordTextField.layer.cornerRadius = 15.0
//        passwordTextField.layer.borderWidth = 1.0
//        passwordTextField.layer.borderColor = gray.cgColor
//        
        loginButtonOutlet.layer.cornerRadius = 15.0
        loginButtonOutlet.layer.borderWidth = 1.0
        loginButtonOutlet.layer.borderColor = gray.cgColor
    }
}
extension SegmentViewController: UICollectionViewDelegateFlowLayout {
    
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
    func percentEncoded() -> Data? {
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
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

