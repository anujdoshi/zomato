//
//  ViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 18/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit
class ViewController: UIViewController ,UICollectionViewDataSource,UICollectionViewDelegate{
    /*
    // MARK: - View's Outlet
    */
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    /*
    // MARK: - Button's Outlet
    */
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    /*
    // MARK: - Extra variable
    */
    let userDefaullt = UserDefaults.standard
    var timer = Timer()
    var counter = 0
    
    var imgArr = [UIImage(named: "food"),UIImage(named: "food1"),UIImage(named: "food2"),UIImage(named: "food3"),UIImage(named: "food4"),UIImage(named: "food5")]
    /*
    // MARK: - View Override method
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        //For change the image every second
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if userDefaullt.bool(forKey: "usersignedin"){
            performSegue(withIdentifier: "goToHome", sender: self)
        }
    }
    /*
    // MARK: - Update UI
    */
    func updateUI(){
        let gray : UIColor = UIColor(red:0.96, green:0.96, blue:0.95, alpha:1.0)
        registerButton.layer.cornerRadius = 15.0
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.borderColor = gray.cgColor
        loginButton.layer.cornerRadius = 15.0
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = gray.cgColor
    }
    /*
    // MARK: - Change Image
    */
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
    // MARK: - Collection View Method
    */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let vc = cell.viewWithTag(111) as? UIImageView {
            vc.image = imgArr[indexPath.row]
        }
        return cell
    }
    /*
    // MARK: - Register Button Action
    */
    @IBAction func registerButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    /*
    // MARK: - Login Button Action
    */
    
    @IBAction func loginButtonPress(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
}
extension ViewController: UICollectionViewDelegateFlowLayout {
    
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

