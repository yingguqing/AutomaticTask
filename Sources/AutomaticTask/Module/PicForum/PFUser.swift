//
//  PFUser.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

class PFUser {
    // 用户名
    let name: String
    // 密码
    let password: String
    // 自己的用户id
    var userId: Int
    // 访问别人空间的id，被访问会增加金币
    var otherUserId: Int = 0
    // 保存在数据文件中的Key
    fileprivate let saveKey: String
    // 历史金币
    private(set) var historyMoney: Int
    // 金币
    var money: Int = 0
    // 序号
    var index: Int
    // 日期
    let date: String
    // 历史数据中的日期是否是今天
    let isToday: Bool
    // 发表评论次数（新手1小时内限发10次，有奖次数为15次）
    var replyTimes: Int
    // 是否访问别人空间
    var isVisitOtherZone: Bool
    // 是否留言
    var isLeaveMessage: Bool
    // 是否发表记录
    var isRecord: Bool
    // 发表日志次数
    var journalTimes: Int
    // 分享次数
    var shareTimes: Int
    // 本次最大评论次数(有奖次数为15，小时内最大评论数为10)
    var maxReplyTimes = 15
    // 发表日志的最大次数
    let maxJournalTimes = 3
    // 最大分享次数
    let maxShareTimes = 3
    // 评论最大失败次数
    var maxReplyFailTimes = 5
    // 留言的最大失败次数
    var maxLeaveMsgFailTimes = 5
    // 发表记录的最大失败次数
    var maxRecordFailTimes = 5
    // 发表日志的最大失败次数
    var maxJournalFailTimes = 5
    // 发表分享的最大失败次数
    var maxShareFailTimes = 5
    
    init?(json: JSON, xor: String) {
        let userName = json["username"].stringValue
        let password = json["password"].stringValue
        guard !userName.isEmpty, !password.isEmpty else {
            return nil
        }
        name = userName
        self.password = password
        saveKey = "HKPIC_CONFIG_\(userName.xorEncrypt(xor))".replacingOccurrences(of: "/", with: "$")
        let config = ATConfig.default.read(key: saveKey) as? [String: Any] ?? [:]
        var userConfig = JSON(config)
        index = userConfig["index"].int ?? -1
        let userId = userConfig["user_id"].intValue
        self.userId = userId
        let oldDate = userConfig["date"].stringValue
        date = Date.today("YYYY-MM-dd")
        isToday = date == oldDate
        if !isToday {
            // 如果数据不是今天的，就不读取，使用默认值
            userConfig = JSON([:])
        }
        // 历史金币：第一次运行时，从网页获取，第二次运行时，从数据文件读取
        historyMoney = userConfig["history_money"].int ?? -1
        replyTimes = userConfig["reply_times"].intValue
        isVisitOtherZone = userConfig["is_visit_other_zone"].bool ?? true
        isLeaveMessage = userConfig["is_leave_message"].bool ?? true
        isRecord = userConfig["is_record"].bool ?? true
        journalTimes = userConfig["journal_times"].intValue
        shareTimes = userConfig["share_times"].intValue
    }
    
    /// 重新获取金币数
    /// - Returns: 金币是否增加
    func reloadMoney() async {
        _ = await moneyPlus()
        if historyMoney < 0 {
            historyMoney = money
        }
    }
    
    /// 金币增加数
    func moneyPlus() async -> Int {
        for _ in [0...5] {
            let tempMoney = await PFNetwork.userMoney(id: userId)
            if tempMoney > -1 {
                let number = tempMoney - money
                money = tempMoney
                return number
            }
        }
        return -1
    }
}

extension PFUser {
    /// 是否需要发表评论
    var canReply: Bool {
        return replyTimes < maxReplyTimes && maxReplyFailTimes > 0
    }
    
    /// 是否需要发表日志
    var canJournal: Bool {
        return journalTimes < maxJournalTimes && maxJournalFailTimes > 0
    }
    
    /// 是否需要发表分享
    var canShare: Bool {
        return shareTimes < maxShareTimes && maxShareFailTimes > 0
    }
    
    /// 是否需要留言
    var canLeaveMessage: Bool {
        return isLeaveMessage && maxLeaveMsgFailTimes > 0
    }
    
    /// 是否需要发表记录
    var canRecord: Bool {
        return isRecord && maxRecordFailTimes > 0
    }
    
    // 新增金钱。格式1：100 = 90 + 10,格式2：+10 -> 100
    func moneyAddition(_ type:Int) -> String {
        guard historyMoney > -1 else { return "\(money)" }
        let temp = money - historyMoney
        guard temp > 0 else { return "\(money)" }
        switch type {
            case 1:
                return "\(money) = \(historyMoney) + \(temp)"
            case 2:
                return "+\(temp) -> \(money)"
            default:
                return "\(money)"
        }
    }

    /// 保存的数据
    fileprivate var saveValue: [String: Any] {
        var value: [String: Any] = [
            "name": name,
            "money": money,
            "date": date,
            "is_visit_other_zone": isVisitOtherZone,
            "reply_times": replyTimes,
            "is_leave_message": isLeaveMessage,
            "is_record": isRecord,
            "journal_times": journalTimes,
            "share_times": shareTimes
        ]
        
        if userId > 999 {
            value["user_id"] = userId
        }
        if index >= 0, index < 99 {
            value["index"] = index
        }
        if money >= historyMoney {
            value["history_money"] = historyMoney
        }
        return value
    }
    
    /// 保存数据
    func save() {
        ATConfig.default.save(key: saveKey, value: saveValue)
    }
}
