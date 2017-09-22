//
//  UIView+Ex.swift
//  InternManager
//
//  Created by apple on 2017/8/25.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import Kingfisher
extension UIView {
    
    func corner() {
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    func superVc()->UIViewController? {
        var superView = self.superview
        while superView != nil{
            let respon = superView?.next
            if respon is UIViewController {
                return respon as? UIViewController
            }
            superView = superView?.superview
        }
        return nil
    }
    
}

extension UITableView{
    func register(str: String){
        self.register(UINib(nibName: str, bundle: nil), forCellReuseIdentifier: str)
    }
}

extension UIImageView{
    func kfImage(_ str: String) {
        self.kf.setImage(with: URL(string: str), placeholder: KPlaceholderImage)
    }
}

extension UIView {
    func iconClicked(superVc: RootViewController, tag: Int) {
        self.tag = tag
        if self.gestureRecognizers?.count == nil {
            self.isUserInteractionEnabled = true
            let tapG = UITapGestureRecognizer(target: superVc, action: #selector(RootViewController.goPersonal(tapG:)))
            self.addGestureRecognizer(tapG)
        }
    }
}

extension UITabBar {
    
}
