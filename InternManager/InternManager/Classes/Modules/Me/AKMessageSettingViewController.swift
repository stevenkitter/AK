//
//  AKMessageSettingViewController.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import SVProgressHUD
class AKMessageSettingViewController: RootViewController {

    var isReceiveNotification = false
    var isShowPush = RCIMClient.shared().pushProfile.isShowPushContent
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        title = "消息设置"
        RCIMClient.shared().getNotificationQuietHours({ (startTime, spansMin) in
            DispatchQueue.main.async {
                if spansMin >= 1439 {
                    self.isReceiveNotification = false
                    self.tableView.reloadData()
                }else{
                    self.isReceiveNotification = true
                    self.tableView.reloadData()
                }
            }
            
        }) { (err) in
            DispatchQueue.main.async {
                self.isReceiveNotification = false
                self.tableView.reloadData()
            }
           
        }
        
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        tableView.register(str: "AKSettingTableViewCell")

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}

extension AKMessageSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AKSettingTableViewCell", for: indexPath) as! AKSettingTableViewCell
        cell.ak_titleLabel.text = indexPath.item == 0 ? "接受新消息通知":"显示推送内容"
        cell.ak_switch.isOn = indexPath.item == 0 ? isReceiveNotification : isShowPush
        cell.switched = {sender in
            if indexPath.item == 1 {
                RCIMClient.shared().pushProfile.updateShowPushContentStatus(sender.isOn, success: {
                    DispatchQueue.main.async {
                        SVProgressHUD.showSuccess(withStatus: "设置成功")
                        
                    }
                }, error: { (err) in
                    DispatchQueue.main.async {
                        SVProgressHUD.showError(withStatus: "设置失败")
                    }
                })
            }else{
                if !sender.isOn {
                    RCIMClient.shared().setNotificationQuietHours("00:00:00", spanMins: 1439, success: {
                        DispatchQueue.main.async {
                            self.isReceiveNotification = false
                            self.tableView.reloadData()
                        }
                    }, error: { (err) in
                        DispatchQueue.main.async {
                            self.isReceiveNotification = true
                            self.tableView.reloadData()
                        }
                    })

                }else{
                    RCIMClient.shared().removeNotificationQuietHours({ 
                        DispatchQueue.main.async {
                            self.isReceiveNotification = true
                            self.tableView.reloadData()
                        }
                    }, error: { (err) in
                        DispatchQueue.main.async {
                            self.isReceiveNotification = false
                            self.tableView.reloadData()
                        }
                    })
                }
                
                
            }
            
        }
        return cell
    }
}
