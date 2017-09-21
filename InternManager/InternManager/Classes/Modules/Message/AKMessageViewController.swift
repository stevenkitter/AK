//
//  AKMessageViewController.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/20.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKMessageViewController: RCConversationListViewController {
    

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "消息"
        self.setDisplayConversationTypes([1])
        conversationListTableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addfriend_icon"), style: .plain, target: self, action: #selector(findPerson))
    }
    
    func updateBadgeValueForTabBarItem(){
        DispatchQueue.main.async {
            let count = RCIMClient.shared().getUnreadCount([1])
            guard let item = self.navigationController?.tabBarController?.tabBar.items?[2] else {return}
            if count > 0 {
                
                item.badgeValue = "\(count)"
            }else{
                item.badgeValue = ""
            }
            
            
            
        }
    }
    
    func findPerson() {
        let vc = AKFindPersonViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {

        guard let conversation = AKChatViewController(conversationType: model.conversationType, targetId: model.targetId) else {return}
        conversation.title = model.conversationTitle
        conversation.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(conversation, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func didReceiveMessageNotification(_ notification: Notification!) {
        
        super.didReceiveMessageNotification(notification)
        updateBadgeValueForTabBarItem()
    }

}
