//
//  AKLinkModel.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/22.
//  Copyright © 2017年 coderX. All rights reserved.
//

import Foundation
import ObjectMapper
struct AKLinkModel: Mappable {
    var link_con: String = ""
    var link_url: String = ""
    var link_title: String = ""
    var file_path: String = ""
    init?(map: Map) {
        
    }
    mutating func mapping(map: Map) {
        link_con <- map["link_con"]
        link_url <- map["link_url"]
        link_title <- map["link_title"]
        file_path <- (map["file_path"], AvatarTransform())
    }
}
