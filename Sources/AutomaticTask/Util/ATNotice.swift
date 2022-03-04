//
//  ATNotice.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

/// 发送手机通知。手机需要下载应用：Bark
class ATNotice: ATBaseTask {
    
    static var `default`:ATNotice = ATNotice(noticeKey: "")
    
    // 通知Key
    var noticeKey: String?
    // 记录所有通知
    private var notices = SafeArray<ATNoticeValue>()
    private var targetNames = SafeArray<String>()
    // 接收通知的目标数
    var targetCounts = 0
    
    private init(noticeKey: String) {
        self.noticeKey = noticeKey
    }
    
    var isValid:Bool {
        return noticeKey?.isEmpty == false && targetCounts > 0
    }
    
    /// 发送一条手机通知信息
    /// - Parameters:
    ///   - text: 通知内容
    ///   - title: 通知标题(可以为空)
    ///   - icon: 通知图标
    ///   - group: 消息分组
    func sendNotice(text: String, title: String = "", icon: String = "", group: String = "", isFinish: Bool = true) {
        guard let noticeKey = noticeKey, !noticeKey.isEmpty, !text.isEmpty else {
            finish(isFinish)
            return
        }
        var data = ATNoticeApiData(noticeKey: noticeKey, text: text)
        data.title = title
        data.icon = icon
        data.group = group
        //print(data.url?.absoluteString ?? "notice------------------------")
        ATRequestManager.default.send(data: data) { result in
            let json = result.data?.json as? [String: Any]
            let code = json?["code"] as? Int
            if code != 200 {
                var msg = [String]()
                if let data = result.data, let m = String(data: data, encoding: .utf8) {
                    msg.append(m)
                }
                if let error = result.error {
                    msg.append(error.localizedDescription)
                }
                print("发送通知失败：\(msg.joined(separator: " | "))")
            }
            self.finish(isFinish)
        }
    }
    
    /// 往通知列表中插入一条
    /// - Parameters:
    ///   - value: 通知内容
    func addNotice(_ value:ATNoticeValue) {
        _wait(); defer { _signal() }
        notices.append(value)
    }
    
    /// 将通知列表中的消息全部发送
    /// - Parameter targetName: 接收通知的目标名称
    func sendAllNotice(targetName: String) {
        _wait(); defer { _signal() }
        targetNames.append(targetName)
        // 等待所有的通知收集完成
        guard Set(targetNames).count == targetCounts else { return }
        guard let noticeKey = noticeKey, !noticeKey.isEmpty, !notices.isEmpty else {
            finish()
            return
        }
        // 以标题进行分类
        let allTitles = Set(notices.map({ $0.title }))
        for title in allTitles {
            let notices = self.notices.filter({ $0.title == title })
                // 对通知进行排序
            let sortList = notices.sorted(by: { $0.index < $1.index })
                // 把列表中的消息拼接
            let text = sortList.map { $0.text }.joined(separator: "\n")
            let notice = notices.first!
            sendNotice(text: text, title: notice.title, icon: notice.icon, group: notice.groupName)
        }
    }
}

extension ATNotice {
    struct ATNoticeValue {
        var title:String = ""
        let groupName:String
        let icon:String
        var text: String = ""
        var index: Int = 99
        init(groupName:String, icon:String) {
            self.groupName = groupName
            self.icon = icon
        }
    }
    
    struct ATNoticeApiData: NetworkData {
        var api: String? {
            let arr = [noticeKey, title.urlEncode, text.urlEncode].filter { !$0.isEmpty }
            let params = ["icon": icon, "group": group].filter { !$0.1.isEmpty }
            var api = arr.joined(separator: "/")
            if !params.isEmpty {
                api.append("?")
                api.append(params.map { "\($0.0)=\($0.1.urlEncode)" }.joined(separator: "&"))
            }
            return api
        }
        
        var method: HttpMethod = .POST
        let host: String = "https://api.day.app"
        let noticeKey: String
        var text: String // 通知内容
        var title: String = "" // 通知标题
        var icon: String = "" // 通知图标
        var group: String = "" // 消息分组
    }
}
