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
        self.setDisplayConversationTypes([RCConversationType.ConversationType_PRIVATE, RCConversationType.ConversationType_GROUP])
        conversationListTableView.tableFooterView = UIView()
        
    }

    override func onSelectedTableRow(_ conversationModelType: RCConversationModelType, conversationModel model: RCConversationModel!, at indexPath: IndexPath!) {

        guard let conversation = RCConversationViewController(conversationType: model.conversationType, targetId: model.targetId) else {return}
        conversation.title = model.conversationTitle
        self.navigationController?.pushViewController(conversation, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
