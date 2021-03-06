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

    public let message = AKMessageViewController()
    
    //title image 
    let titles = ["首页","交流","消息","我的"]
    let unSelectedImageStrs = ["home","inter","circle","me"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewControllers()
        self.delegate = homeVc
    }
    
    func setupChildViewControllers() {
        let subViewControllers = [homeVc,interactVc,message,meVc];
        var subNaviViewController: [RootNavigationController] = []
        for (index,item) in subViewControllers.enumerated() {
            item.tabBarItem.title = titles[index]
            item.tabBarItem.image = UIImage(named: unSelectedImageStrs[index])
            item.tabBarItem.selectedImage = UIImage(named: "\(unSelectedImageStrs[index])_selected")
            item.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: KNaviColor], for: .selected)
            let nav = RootNavigationController(rootViewController: item);
            subNaviViewController.append(nav)
        }
        
        setViewControllers(subNaviViewController, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        message.updateBadgeValueForTabBarItem()
    }
   

}

extension RootTabBarController {
    
}
