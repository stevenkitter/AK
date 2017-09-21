//
//  NetworkManager.swift
//  InternManager
//
//  Created by apple on 2017/8/1.
//  Copyright © 2017年 coderX. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Result
import CryptoSwift




class NetworkManager: NSObject {
    //static let shareNetworkManager = NetworkManager()
    static let endpointClosure = { (target: UserApi) -> Endpoint<UserApi> in
//        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        
        let url = target.baseURL.absoluteString + target.path
        
        print("url:\(url)")
        
        
        let endpoint = Endpoint<UserApi>(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: target.parameters,
            parameterEncoding: target.parameterEncoding
        )
        
        //Set up your header information
       
        return endpoint.adding(newHTTPHeaderFields: ["iOS": "Platform"])
    }
    
    static let circleEndpointClosure = { (target: CircleApi) -> Endpoint<CircleApi> in
        //        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        
        let url = target.baseURL.absoluteString + target.path
        
        print("url:\(url)")
        
        
        let endpoint = Endpoint<CircleApi>(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: target.parameters,
            parameterEncoding: target.parameterEncoding
        )
        
        //Set up your header information
        
        return endpoint.adding(newHTTPHeaderFields: ["iOS": "Platform"])
    }
    
    static let rongEndpointClosure = { (target: RongCloudApi) -> Endpoint<RongCloudApi> in
        //        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        
        let url = target.baseURL.absoluteString + target.path
        
        
        
        
        let endpoint = Endpoint<RongCloudApi>(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            parameters: target.parameters,
            parameterEncoding: target.parameterEncoding
        )
        
        //Set up your header information
        var headFields: [String: String] = ["App-Key": IMAppKey]
        let ram = "\(arc4random_uniform(1000) + 1)"
        headFields["Nonce"] = ram
        let times = String.timestamp()
        headFields["Timestamp"] = times
        let signStr = IMSecret + ram + times
        headFields["Signature"] = signStr.sha1()
        return endpoint.adding(newHTTPHeaderFields: headFields)
    }
    
    static let activityPlugin = NetworkActivityPlugin { (type: NetworkActivityChangeType) in
        switch type{
        case .began:
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        case .ended:
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    static let providerUserApi = RxMoyaProvider<UserApi>(endpointClosure: NetworkManager.endpointClosure,plugins: [NetworkLoggerPlugin(verbose: true),NetworkManager.activityPlugin,RequestPlugin()])
    
    static let providerHomeApi = RxMoyaProvider<HomeApi>(plugins: [NetworkLoggerPlugin(verbose: true),NetworkManager.activityPlugin,RequestPlugin()])
    
    static let providerCircleApi = RxMoyaProvider<CircleApi>(endpointClosure: NetworkManager.circleEndpointClosure,plugins: [NetworkLoggerPlugin(verbose: true),NetworkManager.activityPlugin,RequestPlugin()])
    
    static let providerRongCloudApi = RxMoyaProvider<RongCloudApi>(endpointClosure: NetworkManager.rongEndpointClosure,plugins: [NetworkLoggerPlugin(verbose: true),NetworkManager.activityPlugin,RequestPlugin()])
}




final class RequestPlugin: PluginType {
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            var json:Dictionary? = try! JSONSerialization.jsonObject(with: response.data,options:.allowFragments) as! [String: Any]
            
            guard json?["message"] != nil  else {
                return
            }
            guard let codeString = json?["status"]else {return}
            
            guard codeString as! Int != 1 else{return}
            
            
          
        case .failure(_):
            WXAlertController.alertWithMessageOK(message: "服务器错误", okClosure: nil)
        }
    }
}



extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
