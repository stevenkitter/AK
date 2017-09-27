//
//  AppDelegate.swift
//  InternManager
//
//  Created by apple on 2017/7/31.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let dispose = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initSetup()
        notificationRes(application: application, launchOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let status = RCIMClient.shared().getConnectionStatus()
        if status != .ConnectionStatus_SignUp {
            let unreadMsgCount = RCIMClient.shared().getUnreadCount([1])
            application.applicationIconBadgeNumber = Int(unreadMsgCount)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
       
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

extension AppDelegate:UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    //推送
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        RCIMClient.shared().setDeviceToken(token)
        if let userId = UserManager.shareUserManager.curUserInfo?.id {
            XGPush.registerDevice(deviceToken, account: "userid_" + userId, successCallback: {
                
            }, errorCallback: { 
                
            })
        }else{
            XGPush.registerDevice(deviceToken, successCallback: { 
                
            }, errorCallback: { 
                
            })
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        //收到推送消息 有红点无需跳转
        RCIMClient.shared().recordRemoteNotificationEvent(userInfo)
        XGPush.handleReceiveNotification(userInfo, successCallback: { 
            
        }) { 
            
        }
        if let info = userInfo as? [String: Any] {
            handlePush(userInfo: info)
        }
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        RCIMClient.shared().recordLocalNotificationEvent(notification)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        XGPush.handleReceiveNotification(userInfo, successCallback: { 
            
        }) { 
            
        }
        if let info = userInfo as? [String: Any] {
            handlePush(userInfo: info)
        }
        completionHandler(.newData)
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
        
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        XGPush.handleReceiveNotification(info, successCallback: { 
            
        }, errorCallback: {
            
        })
        if let uinfo = info as? [String: Any] {
            handlePush(userInfo: uinfo)
        }
        completionHandler()
    }
    
}

