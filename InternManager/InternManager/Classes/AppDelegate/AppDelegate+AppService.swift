//
//  AppDelegate+AppService.swift
//  InternManager
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 coderX. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import UserNotifications
import ObjectMapper
//init
extension AppDelegate {
    func initSetup()  {
        //初始化
        initWindow()
        initService()
        iMCloud()
        xGPush()
        initUserManager()
        keyboardManager()
        initShare()
    }
    
    func keyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func initWindow()  {
        self.window = UIWindow(frame: KScreenBounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = LoadingViewController()
        UINavigationBar.appearance().barTintColor = KNaviColor
    }
    //初始化app服务
    func initService()  {
        NotificationCenter.default.addObserver(self, selector: #selector(loginStateChanged(notifi:)), name: NotificationLoginStateChange, object: nil)
        
    }
}

//notification
extension AppDelegate {
    func loginStateChanged(notifi: Notification) {
        if let bol = notifi.object as? Bool {
            guard bol else {
                let logNav = RootNavigationController(rootViewController: LoginViewController())
                self.window?.rootViewController = logNav
                return
            }
            guard let user = UserManager.shareUserManager.curUserInfo else{return}
            guard let userId = user.id else {return}
            guard let token = userId.token() else {
                NetworkManager.providerRongCloudApi.request(.token(userId: userId, name: user.userName(), portraitUri: user.user_avatar ?? "")).mapJSON().subscribe(onNext: { (res) in
                    guard let respon = res as? Dictionary<String, Any> else{
                        return
                    }
                   
                    let code = respon["code"] as? Int
                    let token = respon["token"] as? String
                    if code == 200 {
                        SVProgressHUD.showSuccess(withStatus: "登录成功")
                        userId.saveDefault(value: token ?? "")
                        NotificationCenter.default.post(name: NotificationLoginStateChange, object: true)

                    }else{
                        SVProgressHUD.showError(withStatus: "登录失败，请联系管理员")
                        NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)

                    }

                }, onError: { (err) in
                    NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
                }).addDisposableTo(dispose)
                return
            }
            
            RCIM.shared().connect(withToken: token, success: { (userId) in
                DispatchQueue.main.async {
                    if let currentIMUser = RCUserInfo(userId: userId, name: user.userName(), portrait: user.user_avatar ?? ""){
                        RCIM.shared().currentUserInfo = currentIMUser
                    }
                    
                    let main = RootTabBarController()
                    self.window?.rootViewController = main
                }
                

            }, error: { (err) in
                DispatchQueue.main.async{
                    SVProgressHUD.showError(withStatus: "错误码\(err)，请重新登录")
                    NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
                }
                
            }, tokenIncorrect: {
                DispatchQueue.main.async{
                    SVProgressHUD.showError(withStatus: "token失效，请重新登录")
                    NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
                    let defau = UserDefaults.standard
                    defau.setValue(nil, forKey: userId)
                    defau.synchronize()
                }
                
            })
            
            
        }
    }
}
//localUser
extension AppDelegate {
    func initUserManager() -> Void {
        UserManager.shareUserManager.loadUserInfo()
    }
}

//分享
extension AppDelegate {
    func initShare() {
        ShareSDK.registerActivePlatforms([SSDKPlatformType.typeWechat.rawValue], onImport: { (platform) in
            ShareSDKConnector.connectWeChat(WXApi.classForCoder())
        }) { (platform, appInfo) in
            appInfo?.ssdkSetupWeChat(byAppId: "wx51992ecec5ca43dc",
                                     appSecret: "a48ee6a2672d32f415ef5374e51ed4c5")
        }
    }
}

//环信
extension AppDelegate {
    func iMCloud() {
        RCIM.shared().initWithAppKey(IMAppKey)
        RCIM.shared().enablePersistentUserInfoCache = true
        RCIM.shared().userInfoDataSource = AKIMDataSource.shared
        RCIM.shared().enableTypingStatus = true
        RCIM.shared().enabledReadReceiptConversationTypeList = [1]
        RCIM.shared().enableSyncReadStatus = true
        RCIM.shared().showUnkownMessage = true
        RCIM.shared().showUnkownMessageNotificaiton = true
        RCIM.shared().enableMessageRecall = true
        
        RCIM.shared().connectionStatusDelegate = self
        RCIM.shared().receiveMessageDelegate = self
    }
}
extension AppDelegate{
    func xGPush() {
        //[[XGPush defaultManager] startXGWithAppID:2200262432 appKey:@"I89WTUY132GJ"];
        if let xgS = XGSetting.getInstance() as? XGSetting {
            xgS.enableDebug(true)
        }
        XGPush.startApp(2200263144, appKey: "IH423BE3E3EN")
        XGPush.isPush { (bol) in
            
        }
        registerAPNS()
    }
    func registerAPNS() {
        
        registerPush10()
      
    }
    
    func registerPush10(){
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.badge, .sound, .alert]) { (flag, err) in
                
            }
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            let setting = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
       
    }
    func handlePush(userInfo: [String: Any]) {
        WXAlertController.alertWithMessageOKCancel(message: "有新消息，立刻查看？", okClosure: { (_) in
            self.gotoMsgVc(info: userInfo)
        }) { (_) in
            
        }
    }
    func gotoMsgVc(info: [String: Any]) {
        let pushD = UserDefaults.standard
        pushD.set("push", forKey: "push")
        pushD.synchronize()
        
        guard let _ = info["type"] else{
            return
        }
        guard let model = Article(JSON: info) else {return}
        let vc = ArticleDetailViewController()
        let webStr = WebUrl + (model.article_id ?? "") + "&user_id=" + (UserManager.shareUserManager.curUserInfo?.id ?? "")
        vc.articleID = model.article_id ?? ""
        vc.webURLStr = webStr
        let navi = RootNavigationController(rootViewController: vc)
        self.window?.rootViewController?.present(navi, animated: true, completion: nil)

    }
  
}
//推送
extension AppDelegate {
    func notificationRes(application: UIApplication,launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
       
        
        RCIMClient.shared().recordLaunchOptionsEvent(launchOptions)
        RCIMClient.shared().getPushExtra(fromLaunchOptions: launchOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessageNotification(noti:)), name: NSNotification.Name.RCKitDispatchMessage, object: nil)
        guard let option = launchOptions else {return}
        XGPush.handleLaunching(option, successCallback: {
            
        }) { 
            
        }
        
    }
    func didReceiveMessageNotification(noti: Notification) {
        guard let left = noti.userInfo?["left"] as? Int else{
            return
        }
        if RCIMClient.shared().sdkRunningMode == .background && 0 == left {
            let unreadMsgCount = RCIMClient.shared().getUnreadCount([1])
            UIApplication.shared.applicationIconBadgeNumber = Int(unreadMsgCount)
        }
    }
}

extension AppDelegate: RCIMConnectionStatusDelegate{
    func onRCIMConnectionStatusChanged(_ status: RCConnectionStatus) {
        switch status {
        case .ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT:
            WXAlertController.alertWithMessageOK(message: "您的账号在其他设备登录", okClosure: { (_) in
                NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
            })
        case .ConnectionStatus_TOKEN_INCORRECT:
            WXAlertController.alertWithMessageOK(message: "您的账号Token失效，请重新登录", okClosure: { (_) in
                NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
            })
        case .ConnectionStatus_DISCONN_EXCEPTION:
            WXAlertController.alertWithMessageOK(message: "您的账号被封", okClosure: { (_) in
                NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
            })
        default:
            return
        }
    }
    
}

extension AppDelegate: RCIMReceiveMessageDelegate {
    func onRCIMReceive(_ message: RCMessage!, left: Int32) {
        
    }
    func onRCIMCustomLocalNotification(_ message: RCMessage!, withSenderName senderName: String!) -> Bool {
        return false
    }
    
}
