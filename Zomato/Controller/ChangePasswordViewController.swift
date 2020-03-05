//
//  ChangePasswordViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 05/03/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    //Outlet's
    @IBOutlet var newPasswordTextField: UITextField!
    @IBOutlet var oldPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    /*
    // MARK: - Change Password Button
    */
    @IBAction func changePasswordButton(_ sender: UIButton) {
    }
    
}
