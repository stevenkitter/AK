//
//  AKUserInfoManager.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
class AKUserInfoManager: NSObject {
    static let shared = AKUserInfoManager()
    let dispose = DisposeBag()
    
    func getUserInfo(userId: String, complete: @escaping ((_ user: RCUserInfo)->Void)) {
        NetworkManager.providerUserApi.request(.getUserInfo(userId: userId)).mapObject(AKUserInfo.self)
        .subscribe(onNext: { (info) in
            let user = RCUserInfo()
            user.userId = userId
            user.name = info.userName()
            user.portraitUri = info.user_avatar
            complete(user)
        }, onError: { (err) in
            WXAlertController.alertWithMessageOK(message: "查询不到数据", okClosure: nil)
        }).addDisposableTo(dispose)
    }
}


struct AKUserInfo: Mappable {
    var user_id: String = ""
    var user_name: String = ""
    var user_nickname: String = ""
    var user_phone = ""
    var sex = ""
    var user_avatar = ""
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        user_id <- map["user_id"]
        user_name <- map["user_name"]
        user_nickname <- map["user_nickname"]
        user_phone <- map["user_phone"]
        sex <- map["sex"]
        user_avatar <- (map["user_avatar"], AvatarTransform())
    }
}

extension AKUserInfo{
    func userName()-> String {
        let name = (self.user_nickname).exactStr(one: self.user_name, two: self.user_phone)
        return name
    }
}
