//
//  RongCloudApi.swift
//  InternManager
//
//  Created by apple on 2017/9/20.
//  Copyright © 2017年 coderX. All rights reserved.
//

import Foundation
import Moya

enum RongCloudApi{
    case token(userId: String, name: String, portraitUri: String)
}

extension RongCloudApi: TargetType {
    var baseURL: URL {
        return URL(string: "http://api.cn.ronghub.com")!
    }
    var path: String{
        switch self {
        case .token:
            return "/user/getToken.json"
        }
    }
    var method: Moya.Method {
        return .post
    }
    
    var parameterEncoding: ParameterEncoding{
        return URLEncoding.default
    }
    
    var parameters: [String : Any]? {
        switch self {
        case let .token(userId, name, portraitUri):
            var params: [String: Any] = [:]
            params["userId"] = userId
            params["name"] = name
            params["portraitUri"] = portraitUri
            return params

        }
    }
    var sampleData: Data {
        
        return "[{\"userId\": \"1\", \"Title\": \"Title String\", \"Body\": \"Body String\"}]".data(using: String.Encoding.utf8)!
    }
    
    var task: Task{
        
        return .request
        
        
    }
    var validate: Bool {
        return false
    }

}
