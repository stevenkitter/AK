//
//  MeViewController.swift
//  InternManager
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import SVProgressHUD
class MeViewController: RootViewController {
    var cellData = [["我的消息","我的认证"],["推荐好友","个人设置","消息设置","退出登录"]]
    let headView = MeXHeaderView.instance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        setupRefresh()
        setupNotifi()
        loadServerData()
        self.view.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavi(color: KNaviColor)
        setupUnread()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setClearNavi()
    }
    func setupUnread(){
        self.redCount { [unowned self] (unReadModel) in
            
        }
    }
    func setupUI() {
        automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
            
        }
        tableView.register(UINib(nibName: "MeTableViewCell", bundle: nil), forCellReuseIdentifier: "MeTableViewCell")
        let headViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 135))
        headViewContainer.addSubview(headView)
        tableView.tableHeaderView = headViewContainer
        
        headView.clickedClosure = {[unowned self] (tag: Int) in
            guard self.showLoginMethod() else{
                return
            }
            if tag == 0 {
                // 0 1 2 收藏 发表 积分
                let vc = WXCollectsViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }else if tag == 1 {
                let vc = CircleXViewController()
                vc.user_id = UserManager.shareUserManager.curUserInfo?.id ?? ""
                vc.title = "我发表的"
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        tableView.backgroundColor = UIColor.groupTableViewBackground
        
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 135))
        bgView.backgroundColor = KNaviColor
        bgView.tag = 101
        tableView.insertSubview(bgView, at: 0)
    }
    override func setupRefresh() {
        tableView.mj_header = RefreshHeader(refreshingBlock: { [unowned self] in
            self.loadServerData()
        })
    }
    override func loadServerData() {
        guard let userInfo = UserManager.shareUserManager.curUserInfo else{
            self.tableView.mj_header.endRefreshing()
            WXAlertController.alertWithMessageOK(message: "请先登录", okClosure: nil)
            return
        }
        NetworkManager.providerUserApi.request(.userInfo(user_id: userInfo.id ?? ""))
        .mapObject(UserInfo.self)
        .subscribe(onNext: { [unowned self] (userInfo) in
            UserManager.shareUserManager.curUserInfo = userInfo
            self.setupData()
            self.tableView.mj_header.endRefreshing()
        }, onError: { (error) in
            self.tableView.mj_header.endRefreshing()
        }).addDisposableTo(disposeBag)
    }
    
    func setupData() {
        headView.userInfo = UserManager.shareUserManager.curUserInfo
    }
    
    func setupNotifi(){
        NotificationCenter.default
            .rx.notification(UserInfoChanged).subscribe(onNext: { [unowned self] (_) in
                self.tableView.mj_header.beginRefreshing()
                }, onError: { (erro) in
                    
            }).addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
}
extension MeViewController: UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = cellData[section]
        return sec.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let secs = cellData[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeTableViewCell", for: indexPath) as! MeTableViewCell
        cell.titleLabel.text = secs[indexPath.row]
        cell.iconImageView.image = UIImage(named: secs[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let secs = cellData[indexPath.section]
        let str = secs[indexPath.row]
        guard self.showLoginMethod() else{
            return
        }
        let user = UserManager.shareUserManager.curUserInfo
        if str == "我的消息" {
            let vc = WXMessagesViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if str == "我的认证" {
            let words = "您的手机号：\(user?.user_phone ?? ""),已认证成功！"
            SVProgressHUD.showSuccess(withStatus: words)
        
        }else if str == "推荐好友" {
            shareSDK()
        }else if str == "个人设置" {
            let vc = WXEditMeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else if str == "退出登录" {
            logoutMethod()
        }else if str == "消息设置" {
            messgeSetting()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
}
//:MARK private
extension MeViewController {
    func logoutMethod() {
        WXAlertController.alertWithMessageOKCancel(message: "确认退出？", okClosure: { [unowned self] (alertA) in
            UserManager.shareUserManager.logout()
            self.setupData()
        }) { (alertA) in
            
        }
    }
    
    func showLoginMethod()-> Bool {
        
        return showLoginWithClosure { [unowned self] in
            self.loadServerData()
        }
        
    }
    
    func messgeSetting() {
        let vc = AKMessageSettingViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shareSDK() {
        let shareParames = NSMutableDictionary()
        shareParames.ssdkSetupShareParams(byText: "推荐你使用AK官网",
                                          images : [UIImage(named: "icon-40"),UIImage(named: "icon-40"),UIImage(named: "icon-40")],
                                          url : NSURL(string:"http://www.akwangdai.com:8002/admin/article/getWebView?article_id=21") as URL!,
                                          title : "AK官网",
                                          type : SSDKContentType.auto)
        
        //2.进行分享
        ShareSDK.showShareActionSheet(self.view, items: nil, shareParams: shareParames) { (state, platform, param, entity, err, flag) in
            switch state{
                
            case SSDKResponseState.success: print("分享成功")
            case SSDKResponseState.fail:    print("授权失败,错误描述:\(err.debugDescription)")
            case SSDKResponseState.cancel:  print("操作取消")
                
            default:
                break
            }

        }
        
    }
}
extension MeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        let space = -point.y
        if space > 0 {
            var rect = tableView.viewWithTag(101)!.frame
            rect.origin.y = -space
            rect.size.height = 135 + space
            tableView.viewWithTag(101)!.frame = rect
        }
    }
}

