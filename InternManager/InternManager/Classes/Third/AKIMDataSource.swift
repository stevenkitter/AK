//
//  AKIMDataSource.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKIMDataSource: NSObject {
    static let shared = AKIMDataSource()
}

extension AKIMDataSource : RCIMUserInfoDataSource {
    func getUserInfo(withUserId userId: String!, completion: ((RCUserInfo?) -> Void)!) {
        let user = RCUserInfo()
        if userId.characters.count == 0 {
            user.userId = userId
            user.name = ""
            user.portraitUri = ""
            completion(user)
            return
        }
        
        guard let curUser = UserManager.shareUserManager.curUserInfo else {return}
        if curUser.id == userId {
            user.userId = userId
            user.name = curUser.userName()
            user.portraitUri = curUser.user_avatar ?? ""
            completion(user)
            return
        }
        AKUserInfoManager.shared.getUserInfo(userId: userId) { (user) in
            completion(user)
            return
        }
    }
}
