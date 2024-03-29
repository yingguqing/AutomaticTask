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
    let noticeValue: ATNotice.ATNoticeValue
    
    /// 所有用户
    lazy var users: [PFUser] = {
        let users = accounts.compactMap { PFUser(json: JSON($0), xor: xor) }
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
    
    private init(json: JSON) {
        let xor = json["xor"].stringValue
        self.xor = xor
        host = json["host"].stringValue
        hostURL = json["hostURL"].stringValue
        accounts = json["accounts"].arrayObject as? [[String: String]] ?? []
        let noticeIcon = json["noticeIcon"].stringValue
        let groupName = json["groupName"].stringValue
        noticeValue = ATNotice.ATNoticeValue(groupName: groupName, icon: noticeIcon)
    }
    
    func update(json: JSON) {
        PFConfig.default = PFConfig(json: json)
    }
    
    func fullURL(_ api: String) -> String {
        return host.urlAppendPathComponent(api)
    }
    
    /// 执行比思所有用户的行为
    func run(isDebug: Bool) -> [AutomaticTask] {
        let pics = users.map({ PicForum(user: $0, isDebug: isDebug) }) /* .filter({ $0.name == "yingguqing" }) */
        DispatchQueue.global().async {
            // 寻找最优级域名，其他域名会造成发表失败（抱歉，您的請求來路不正確或表單驗證串不符，無法提交），暂时没有解决方案
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
    
    /// 通过域名发布地址，查找最优级域名(功能不好用，以后有更好的方法时再修改)
    func findBestHost() async {
        defer { print("本次最优域名：\(self.host)") }
        guard !hostURL.isEmpty else { return }
        let allHostData = await ATRequestManager.default.send(data: hostURL)
        guard let allHostString = allHostData.data?.text else { return }
        let array = allHostString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "").components(separatedBy: "<br>").filter({ !$0.isEmpty })
        if let index = array.firstIndex(of: "比思永久域名") {
            // 提取所有域名
            let hosts = [self.host] + array.prefix(index).filter({ $0.hasPrefix("http") })
            var hostDic = [String: Double]()
            let maxCount = 5
            for _ in 0 ..< maxCount {
                // 测试延时最短的域名
                for host in hosts {
                    let url = host.urlAppendPathComponent(PFNetwork.API.Home.api)
                    let star = Date().timeIntervalSince1970
                    let data = await ATRequestManager.default.send(data: url, faildTimes: -1)
                    let time: Double
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
            self.host = best?.0 ?? self.host
        }
    }
}
