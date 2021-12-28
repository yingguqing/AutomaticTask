//
//  ATNotice.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

class ATNotice: ATBaseTask {
    // 通知Key
    let noticeKey: String
    // 通知icon
    let noticeIcon: String
    // 通知分组
    let groupName: String
    // 记录所有通知
    private var notices = SafeArray<ATNoticeValue>()
    private var targetNames = SafeArray<String>()
    // 接收通知的目标数
    var targetCounts = 0
    
    init(json: [String: Any]) {
        noticeKey = json.value(key: "noticeKey", defaultValue: "")
        noticeIcon = json.value(key: "noticeIcon", defaultValue: "")
        groupName = json.value(key: "groupName", defaultValue: "")
    }
    
    /// 发送一条手机通知信息
    /// - Parameters:
    ///   - text: 通知内容
    ///   - title: 通知标题(可以为空)
    ///   - icon: 通知图标
    ///   - group: 消息分组
    func sendNotice(text: String, title: String = "", icon: String = "", group: String = "", isFinish:Bool=true) {
        guard !noticeKey.isEmpty, !text.isEmpty else {
            finish(isFinish)
            return
        }
        var data = ATNoticeApiData(noticeKey: noticeKey, text: text)
        data.title = title
        data.icon = icon
        data.group = group
        ATRequestManager.default.asyncSend(data: data) { result in
            let json = result.data?.json as? [String: Any]
            let code = json?["code"] as? Int
            if code != 200 {
                var msg = ""
                if let data = result.data {
                    msg = String(data: data, encoding: .utf8) ?? ""
                }
                if let error = result.error {
                    msg.append(" | \(error.localizedDescription)")
                }
                print("发送通知失败：\(msg)")
            }
            self.finish(isFinish)
        }
    }
    
    /// 往通知列表中插入一条
    /// - Parameters:
    ///   - text: 通知内容
    ///   - index: 插入位置（小于0表示添加到末尾）
    func addNotice(text: String, index: Int = -1) {
        _wait(); defer { _signal() }
        let noti = ATNoticeValue(text: text, index: index >= 0 ? index : Int.max)
        notices.append(noti)
    }
    
        /// 将通知列表中的消息全部发送
        /// - Parameter title: 通知标题
        /// - Parameter targetName: 接收通知的目标名称
    func sendAllNotice(title: String, targetName:String) {
        _wait(); defer { _signal() }
        targetNames.append(targetName)
        guard Set(targetNames).count == targetCounts else { return }
        guard !noticeKey.isEmpty, !notices.isEmpty else {
            finish()
            return
        }
        // 对通知进行排序
        let sortList = notices.sorted(by: { $0.index < $1.index })
        // 把列表中的消息拼接
        let text = sortList.map { $0.text }.joined(separator: "\n")
        sendNotice(text: text, title: title, icon: noticeIcon, group: groupName)
    }
}

extension ATNotice {
    struct ATNoticeValue {
        let text: String
        let index: Int
    }
    
    struct ATNoticeApiData: NetworkData {
        var api: String {
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
