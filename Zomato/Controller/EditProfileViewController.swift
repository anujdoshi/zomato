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
    /*
    // MARK: - View Override Methods
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    /*
    // MARK: - Edit Profile Button
    */
    @IBAction func editProfileButton(_ sender: UIButton) {
        
    }
    /*
    // MARK: - Get Profile API
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
                    
                }
            }
        }
        task.resume()
    }
}
