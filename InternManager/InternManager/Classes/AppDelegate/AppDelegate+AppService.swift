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
        
    }
}

extension AppDelegate {
    
}
