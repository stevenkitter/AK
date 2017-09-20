//
//  RootTabBarController.swift
//  InternManager
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit


class RootTabBarController: UITabBarController {
    //控制器的4个自控制器
    public let homeVc = HomeViewController()
    public let interactVc = InteractViewController()
    public let meVc = MeViewController()
    public let friend = AKFriendsViewController()
    public let message = AKMessageViewController()
    
    //title image 
    let titles = ["首页","交流","联系人","消息","我的"]
    let unSelectedImageStrs = ["home","inter","friend","circle","me"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewControllers()
    }
    
    func setupChildViewControllers() {
        let subViewControllers = [homeVc,interactVc,friend,message,meVc];
        var subNaviViewController: [RootNavigationController] = []
        for (index,item) in subViewControllers.enumerated() {
            item.tabBarItem.title = titles[index]
            item.tabBarItem.image = UIImage(named: unSelectedImageStrs[index])
            item.tabBarItem.selectedImage = UIImage(named: "\(unSelectedImageStrs[index])_selected")
            let nav = RootNavigationController(rootViewController: item);
            subNaviViewController.append(nav)
        }
        
        setViewControllers(subNaviViewController, animated: true)
    }
    
   

}

extension RootTabBarController {
    
}
