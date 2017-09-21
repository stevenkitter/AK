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
//init
extension AppDelegate {
    func initSetup()  {
        //初始化
        initWindow()
        initService()
        iMCloud()
        initUserManager()
        keyboardManager()
    
    }
    
    func keyboardManager() {
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func initWindow()  {
        self.window = UIWindow(frame: KScreenBounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController = LoadingViewController()
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
                SVProgressHUD.showError(withStatus: "错误码\(err)，请重新登录")
                NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
            }, tokenIncorrect: { 
                SVProgressHUD.showError(withStatus: "token失效，请重新登录")
                NotificationCenter.default.post(name: NotificationLoginStateChange, object: false)
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
//推送
extension AppDelegate {
    func notificationRes(application: UIApplication,launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        let setting = UIUserNotificationSettings(types: [.badge,.alert,.sound], categories: nil)
        application.registerUserNotificationSettings(setting)
        RCIMClient.shared().recordLaunchOptionsEvent(launchOptions)
        RCIMClient.shared().getPushExtra(fromLaunchOptions: launchOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessageNotification(noti:)), name: NSNotification.Name.RCKitDispatchMessage, object: nil)
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
