//
//  PFConfig.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

class PFConfig {
    static var `default` = PFConfig(json: [:])
    /// 异或key值
    private let xor: String
    /// 域名
    var host: String
    /// 域名发布地址
    let hostURL: String
    /// 通知系统
    private let notice:ATNotice
    /// 所有账号信息
    private let accounts: [[String: String]]
    /// 所有用户
    lazy var users: [PFUser] = {
        let users = accounts.compactMap { PFUser(json: $0, xor: xor) }
        guard users.count > 1 else { return users }
        // 循环互换用户id用来访问空间，因为访问空间会增加金币
        for (index, user) in users.enumerated() {
            let i = index + 1
            if i < users.count {
                user.otherUserId = users[i].userId
            } else {
                user.otherUserId = users[0].userId
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
        notice = ATNotice(json: json)
    }
    
    func fullURL(_ api: String) -> String {
        return host.urlAppendPathComponent(api)
    }
    
    /// 执行比思所有用户的行为
    func run(_ taskArray:inout SafeArray<AutomaticTask>) {
        // 寻找最优级域名
        findBestHost()
        let pics = users.map({ PicForum(user: $0, notice: notice) })
        taskArray += pics
        if !pics.isEmpty {
            taskArray.append(notice)
            notice.targetCounts += users.count
        }
        for pic in pics {
            DispatchQueue.global().async {
                pic.run()
            }
            sleep(1)
        }
    }
    
    /// 通过域名发布地址，查找最优级域名
    func findBestHost() {
        defer { print("本次最优域名：\(self.host)") }
        guard !hostURL.isEmpty else { return }
        let allHostData = ATRequestManager.default.syncSend(url: hostURL)
        guard let allHostString = allHostData.data?.text else { return }
        let array = allHostString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").components(separatedBy: "<br>").filter({ !$0.isEmpty })
        if let index = array.firstIndex(of: "比思永久域名") {
            // 提取所有域名
            let hosts = [self.host] + array.prefix(index).filter({ $0.hasPrefix("http")})
            var bestHost = ""
            var bestTime:Double = 999
            // 测试延时最短的域名
            for host in hosts {
                let url = host.urlAppendPathComponent(PFNetwork.API.Home.api)
                let star = Date().timeIntervalSince1970
                let data = ATRequestManager.default.syncSend(url: url)
                if data.data?.text?.contains("比思論壇") == true {
                    let time = Date().timeIntervalSince1970 - star
                    guard time < bestTime else { continue }
                    bestTime = time
                    bestHost = host
                }
            }
            guard !bestHost.isEmpty else { return }
            self.host = bestHost
        }
    }
}
