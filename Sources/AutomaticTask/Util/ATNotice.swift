//
//  ATNotice.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

struct ATNoticeValue {
    let text: String
    let index: Int
}

class ATNotice: Safe {
    internal let semaphore = DispatchSemaphore(value: 1)
    // 通知Key
    let noticeKey: String
    // 通知icon
    let noticeIcon: String
    // 通知分组
    let groupName: String
    // 记录所有通知
    private var notices = SafeArray<ATNoticeValue>()
    
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
    func sendNotice(text: String, title: String = "", icon: String = "", group: String = "") {
        _wait(); defer { _signal() }
        guard !noticeKey.isEmpty, !text.isEmpty else { return }
        var urlString = "https://api.day.app/\(noticeKey)/"
        var path = [String]()
        // 加入标题
        if !title.isEmpty {
            path.append(title.urlEncode)
        }
        // 加入内容
        path.append(text.urlEncode)
        urlString += path.joined(separator: "/")
        var query = [String: String]()
        // 知图标
        if !icon.isEmpty {
            query["icon"] = icon
        }
        // 消息分组
        if !group.isEmpty {
            query["group"] = group
        }
        
        if !query.isEmpty {
            urlString += "?\(query.map { "\($0.0)=\($0.1)" }.joined(separator: "&"))"
        }
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            let json = data?.json as? [String: Any]
            let code = json?["code"] as? Int
            if code != 200 {
                var msg = ""
                if let data = data {
                    msg = String(data: data, encoding: .utf8) ?? ""
                }
                if let error = error {
                    msg.append(" | \(error.localizedDescription)")
                }
                print("发送通知失败：\(msg)")
            }
        }
        task.resume()
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
    func sendAllNotice(title: String) {
        _wait(); defer { _signal() }
        guard !noticeKey.isEmpty, !notices.isEmpty else { return }
        // 对通知进行排序
        let sortList = notices.sorted(by: { $0.index < $1.index })
        // 把列表中的消息拼接
        let text = sortList.map { $0.text }.joined(separator: "\n")
        sendNotice(text: text, title: title, icon: noticeIcon, group: groupName)
    }
}
