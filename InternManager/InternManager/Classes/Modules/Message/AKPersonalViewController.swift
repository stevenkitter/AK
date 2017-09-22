//
//  AKPersonalViewController.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKPersonalViewController: RootViewController {
    var userId = ""
    var user: AKUserInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = user.userName()
      
        // Do any additional setup after loading the view.
    }
    func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        tableView.register(str: "AKPersonTableViewCell")
        
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 70))
        let btn = UIButton(type: .custom)
        footView.addSubview(btn)
        btn.snp.makeConstraints { (make) in
            make.edges.equalTo(footView).inset(UIEdgeInsetsMake(10, 10, 10, 10))
        }
        btn.corner()
        btn.setBackgroundImage(UIColor.flatGreen.createImage(), for: .normal)
        btn.addTarget(self, action: #selector(chat), for: .touchUpInside)
        btn.setTitle("发消息", for: .normal)
        tableView.tableFooterView = footView
    }
    
    
    
    func chat() {
        guard let conversation = AKChatViewController(conversationType: RCConversationType.ConversationType_PRIVATE, targetId: user.user_id) else {return}
        conversation.title = user.userName()
        self.navigationController?.pushViewController(conversation, animated: true)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}


extension AKPersonalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AKPersonTableViewCell", for: indexPath) as! AKPersonTableViewCell
        cell.iconImageView.kfImage(user.user_avatar)
        cell.usernameLabel.text = user.userName() + (user.sex == "男" ? "🙎🏻‍♂️" : "🙎🏻")
        cell.userIdLabel.text = user.user_id
        cell.userPhoneLabel.text = user.user_phone
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
