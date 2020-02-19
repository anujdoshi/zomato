//
//  SegmentViewController.swift
//  Zomato
//
//  Created by Anuj Doshi on 19/02/20.
//  Copyright © 2020 Anuj Doshi. All rights reserved.
//

import UIKit

class SegmentViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    var timer = Timer()
    var counter = 0
    
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    var vc1 : UIView!
    var vc2 : UIView!
    var imgArr = [UIImage(named: "food"),UIImage(named: "food1"),UIImage(named: "food2"),UIImage(named: "food3"),UIImage(named: "food4"),UIImage(named: "food5")]

    override func viewDidLoad() {
        super.viewDidLoad()
        vc1  = UIViewController(nibName: "LoginViewController", bundle: nil).view
        vc2 = UIViewController(nibName: "RegisterViewController", bundle: nil).view
//        containerView.addSubview(vc1)
//        containerView.addSubview(vc2)
        scrollViewOutlet.addSubview(vc1)
        scrollViewOutlet.addSubview(vc2)
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }

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
        if let vc = cell.viewWithTag(111) as? UIImageView {
            vc.image = imgArr[indexPath.row]
        }
        return cell
    }
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            vc1.isHidden = true
            vc2.isHidden = false
            break
        case 1:
              vc1.isHidden = false
              vc2.isHidden = true
            break
        default:
            break
        }
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
