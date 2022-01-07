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
    /// 所有账号信息
    private let accounts: [[String: String]]
    // 通知消息的基本数据
    let noticeValue:ATNotice.ATNoticeValue
    
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
    
    private init(json: [String: Any]) {
        let xor = json["xor"] as? String ?? ""
        self.xor = xor
        host = json["host"] as? String ?? ""
        hostURL = json["hostURL"] as? String ?? ""
        accounts = json["accounts"] as? [[String: String]] ?? []
        let noticeIcon = json.value(key: "noticeIcon", defaultValue: "")
        let groupName = json.value(key: "groupName", defaultValue: "")
        noticeValue =  ATNotice.ATNoticeValue(groupName: groupName, icon: noticeIcon)
    }
    
    func update(json:[String: Any]) {
        PFConfig.default = PFConfig(json: json)
    }
    
    func fullURL(_ api: String) -> String {
        return host.urlAppendPathComponent(api)
    }
    
    /// 执行比思所有用户的行为
    func run() -> [AutomaticTask] {
        let pics = users.filter({ $0.name != "yingguqing" }).map({ PicForum(user: $0) })
        DispatchQueue.global().async {
            // 寻找最优级域名
            // self.findBestHost()
            for pic in pics {
                DispatchQueue.global().async {
                    pic.run()
                }
                sleep(1)
            }
        }
        return pics
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
            var hostDic = [String:Double]()
            for _ in 0...5 {
                // 测试延时最短的域名
                for host in hosts {
                    let url = host.urlAppendPathComponent(PFNetwork.API.Home.api)
                    let star = Date().timeIntervalSince1970
                    let data = ATRequestManager.default.syncSend(url: url, faildTimes: -1)
                    let time:Double
                    if data.data?.text?.contains("比思論壇") == true {
                        time = Date().timeIntervalSince1970 - star
                    } else {
                        time = 20
                    }
                    let totalTime = (hostDic[host] ?? 0) + time
                    hostDic[host] = totalTime
                }
            }
            // 取出多次测试，总延时最短的
            let best = hostDic.min(by: { $0.1 < $1.1 })
            self.host = best?.0 ?? host
        }
    }
}
