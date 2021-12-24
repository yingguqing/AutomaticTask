//
//  PFConfig.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

class PFConfig {
    static var `default` = PFConfig(json: [:])
    
    let xor: String
    let host: String
    let hostURL: String
    let accounts: [[String: String]]
    lazy var users: [PFUser] = {
        let users = accounts.compactMap { PFUser(json: $0, xor: xor) }
        // 循环互换用户id用来访问空间，因为访问空间会增加金币
        if users.count > 1 {
            for (index, user) in users.enumerated() {
                let i = index + 1
                if i < users.count {
                    user.otherUserId = users[i].userId
                } else {
                    user.otherUserId = users[0].userId
                }
            }
        }
        return users
    }()
    
    init(json: [String: Any]) {
        let xor = json["xor"] as? String ?? ""
        self.xor = xor
        host = json["host"] as? String ?? ""
        hostURL = json["hostURL"] as? String ?? ""
        accounts = json["accounts"] as? [[String: String]] ?? []
    }
    
    func fullURL(_ api: String) -> String {
        return host.urlAppendPathComponent(api)
    }
}
