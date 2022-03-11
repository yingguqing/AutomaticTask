//
//  PicForum.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

// 比思发表类型
enum PicType: String {
    case Reply = "评论"
    case LeaveMessage = "留言"
    case Record = "记录"
    case Journal = "日志"
    case Share = "分享"
    case Other = "其他"
    
    // 比思各类型发表需要休息时间
    var sleepSec: UInt32 {
        switch self {
            case .Reply:
                return 58
            case .Journal, .LeaveMessage:
                return 55
            case .Record:
                return 51
            case .Share:
                return 3
            case .Other:
                return 2
        }
    }
}

// 比思
class PicForum: ATBaseTask {
    // 开始时间
    let starTime: Double = Date().timeIntervalSince1970
    // 休息时长
    var sleepTime: UInt32 = 0
    // 用户
    let user: PFUser
    // 提交内容时需要
    var formhash = ""
    // 是否需要签到
    var isSignIn = false
    // 记录发表状态，用于休息
    var isSend = false
    // 日志系统
    let log: ATPrintLog
    // 帖子较多的板块
    lazy var fids = [2, 10, 11, 18, 20, 31, 42, 50, 79, 117, 123, 135, 142, 153, 239, 313, 398, 445, 454, 474, 776, 924].shuffled()
    // 所有评论内容，随机使用
    lazy var comments = [
        "走过了年少，脚起了水泡。", "人生自古谁无死，啊个拉屎不用纸！", "如果跟导师讲不清楚，那么就把他搞胡涂吧！",
        "不要在一棵树上吊死，在附近几棵树上多试试死几次。", "老天，你让夏天和冬天同房了吧？生出这鬼天气！",
        "怀揣两块，胸怀500万！", "恋爱就是无数个饭局，结婚就是一个饭局。", "男人靠的住，母猪能上树！",
        "要是我灌水，就骂我“三个代表”没学好吧。", "天塌下来你顶着，我垫着！", "美女未抱身先走，常使色狼泪满襟。",
        "穿别人的鞋，走自己的路，让他们找去吧。", "自从我变成了狗屎，就再也没有人踩在我头上了。",
        "我怀疑楼主用的是金山快译且额外附带了中对中翻译。", "丑，但是丑的特别，也就是特别的丑！", "路边的野花不要，踩。",
        "流氓不可怕，就怕流氓有文化。", "听君一席话，省我十本书！", "如果有一双眼睛陪我一同哭泣，就值得我为生命受苦。",
        "生我之前谁是我，生我之后我是谁？", "人生重要的不是所站的位置，而是所朝的方向！", "内练一口气，外练一口屁。",
        "找不到恐龙，就用蜥蜴顶。", "俺从不写措字，但俺写通假字！", "如果恐龙是人，那人是什么？",
        "女，喜甜食，甚胖！该女有一癖好：痛恨蚂蚁，见必杀之。问其故曰：这小东西，那么爱吃甜食，腰还那么细！",
        "不在放荡中变坏，就在沉默中变态！", "只要不下流，我们就是主流！", "月经不仅仅是女人的痛苦，也是男人的痛苦。",
        "佛曰，色即是空，空即是色！今晚，偶想空一下。", "勿以坑小而不灌，勿以坑大而灌之。", "读书读到抽筋处，文思方能如尿崩！",
        "睡眠是一门艺术——谁也无法阻挡我追求艺术的脚步！", "人生不能像做菜、把所有的料都准备好才下锅！", "锻炼肌肉，防止挨揍！",
        "我妈常说，我们家要是没有电话就不会这么穷。", "我不在江湖，但江湖中有我的传说。", "我喜欢孩子，更喜欢造孩子的过程！",
        "时间永远是旁观者，所有的过程和结果，都需要我们自己承担。", "其实我是一个天才，可惜天妒英才！", "站的更高，尿的更远。",
        "漏洞与补丁齐飞，蓝屏共死机一色！", "比我有才的都没我帅，比我帅的都没我有才！", "我身在江湖，江湖里却没有我得传说。",
        "有来有往，你帮我挖坑，我买一送一，填埋加烧纸。", "所有的男人生来平等，结婚的除外。", "不在课堂上沉睡，就在酒桌上埋醉。",
        "只有假货是真的，别的都是假的！", "男人有冲动可能是爱你，也可能是不爱，但没有冲动肯定是不爱！", "我在马路边丢了一分钱！",
        "商女不知亡国恨、妓女不懂婚外情。", "脱了衣服我是禽兽，穿上衣服我是衣冠禽兽！", "你的丑和你的脸没有关系。",
        "鸳鸳相抱何时了，鸯在一边看热闹。", "长得真有创意，活得真有勇气！", "走自己的路，让别人打车去吧。",
        "男人与女人，终究也只是欲望的动物吧！真的可以因为爱而结合吗？对不起，我也不知道。", "有事秘书干，没事干秘书！",
        "关羽五绺长髯，风度翩翩，手提青龙偃月刀，江湖人送绰号——刀郎。", "解释就系掩饰，掩饰等于无出色，无出色不如回家休息！",
        "勃起不是万能的，但不能勃起却是万万都不能的！", "沒有激情的亲吻，哪來床上的翻滾？", "做爱做的事，交配交的人。",
        "有时候，你必须跌到你从未经历的谷底，才能再次站在你从未到达的高峰。", "避孕的效果：不成功，便成“人”。",
        "与时俱进，你我共赴高潮！", "恐龙说：“遇到色狼，不慌不忙；遇到禽兽，慢慢享受。", "生，容易。活，容易。生活，不容易。",
        "人家解释，我想，这世界上又要多我这一个疯子了。", "长大了娶唐僧做老公，能玩就玩一玩，不能玩就把他吃掉。",
        "此地禁止大小便，违者没收工具。", "昨天，系花对我笑了一下，乐得我晚上直数羊，一只羊，两只羊，三只羊。",
        "我靠！看来医生是都疯了！要不怎么让他出院了！", "打破老婆终身制，实行小姨股份制。引入小姐竞争制，推广情人合同制。"
    ].shuffled()
    
    // 网络请求的默认数据
    lazy var defaultData: PFNetwork.PFNetworkData = PFNetwork.PFNetworkData(header: PFNetwork.PFNetworkData.defaultHeader, .Home)
    // 网络
    lazy var network: PFNetwork = {
        let net = PFNetwork()
        net.log = log
        return net
    }()
    
    init(user: PFUser) {
        self.user = user
        self.log = ATPrintLog(title: user.name)
        #if Xcode
        self.log.isDebug = true
        #endif
        super.init()
        super.timeout = 3000
    }
    
    func run() {
        defer { finish() }
        log.print(text: "------------- \(user.name) 比思签到 -------------", type: .Normal)
        if user.historyMoney < 0 {
            log.print(text: "获取历史金钱失败", type: .Faild)
        }
        // 登录
        guard login() else { return }
        // 签到
        signIn()
        // 评论
        forumList(true)
        // 访问别人空间并留言
        visitUserZone()
        // 留言
        leavMessage()
        // 发表一条记录
        record()
        // 删除发表的记录
        deleteRecord()
        // 发表日志
        journal()
        // 删除脚本发表的日志
        delJournal()
        // 发表分享
        share()
        // 删除自己空间留言所产生的动态
        deleteAllleavMessageDynamic()
        user.reloadMoney()
        user.save()
        log.print(text: "金钱：\(user.moneyAddition(1))", type: .Cyan)
        log.print(text: "休息：\(Double(sleepTime).timeFromat)", type: .White)
    }
    
    /// 比思结束
    override func finish(_ finish: Bool = true) {
        // 统计执行时长
        let total = Date().timeIntervalSince1970 - starTime
        log.print(text: "------------- 签到完成,耗时\(total.timeFromat) -------------", type: .Normal)
        log.printLog()
        super.finish(finish)
        var noticeValue = PFConfig.default.noticeValue
        noticeValue.text = "\(user.name):\(user.moneyAddition(2))"
        noticeValue.index = user.index
        noticeValue.title = "比思金币"
        ATNotice.default.addNotice(noticeValue)
        ATNotice.default.sendAllNotice(targetName: user.name)
    }
    
    /// 访问首页
    /// - Parameters:
    ///   - host: 域名
    ///   - isCheckHost: 是否测试域名
    ///   - complete: 完成回调
    private func forum(host: String? = nil, isCheckHost: Bool = false) {
        let data = network.html(data: defaultData)
        // 提取自己的用户id
        let regex = try! Regex("<a\\s*href=\"space-uid-(\\d{5,}).html\"\\s*target=\"_blank\"\\s*title=\"訪問我的空間\">\(user.name)</a>")
        if let userId = regex.firstGroup(in: data.html), let id = Int(userId) {
            user.userId = id
        }
        // 是否需要签到
        isSignIn = data.findSuccess(txt: "簽到領獎!")
        
        // 提取formhash
        let formhashRegex = try! Regex("formhash=(\\w+)")
        if let formhash = formhashRegex.firstGroup(in: data.html)?.trimmingCharacters(in: .whitespaces), !formhash.isEmpty {
            self.formhash = formhash
        } else {
            log.print(text: "formhash获取失败", type: .Faild)
        }
        
        // 没有别人的空间地址时，提取首页随便一个人非自己的空间地址
        if user.otherUserId < 9999 {
            let regex = try! Regex("\"space-uid-(\\d{5,}).html\"")
            let allUid = regex.matches(in: data.html).map { $0.captures.compactMap { $0 } }.flatMap { $0 }.compactMap { Int($0) }
            if let id = allUid.filter({ $0 > 9999 && $0 != user.userId }).first {
                user.otherUserId = id
            }
        }
    }
    
    /// 登录
    @discardableResult private func login() -> Bool {
        var param = defaultData
        param.body = ["username": user.name, "password": user.password]
        param.type = .Login
        let data = network.html(data: param)
        if !data.cdata.isEmpty {
            forum()
            return true
        } else {
            log.print(texts: ["登录失败", data.html], type: .Faild)
            return false
        }
    }
    
    /// 签到
    private func signIn() {
        guard isSignIn else { return }
        var param = defaultData
        param.body = ["formhash": formhash]
        param.type = .SignIn
        let data = network.html(data: param)
        let regex = try! Regex("<div\\s+class\\s*=\\s*\"c\"\\s*>\\W*(.*?)\\W*<\\s*/\\s*div\\s*>")
        if let text = regex.firstGroup(in: data.html) {
            log.print(text: text, type: .Success)
        } else {
            log.print(texts: ["签到失败", data.html], type: .Faild)
        }
    }
    
    /// 版本帖子列表
    /// - Parameter isFirst: 是否是第一次获取，如果是的话会打印日志，并获取一下现有金币
    private func forumList(_ isFirst: Bool = false) {
        guard user.canReply, !fids.isEmpty else { return }
        // 版块id
        let fid = fids.removeFirst()
        // 页码
        let page = Int.random(in: 3...10)
        var param = defaultData
        param.apiValue = ["fid": String(fid), "page": String(page)]
        param.type = .ForumList
        // 版本排序：最后发贴，防止 180 天以前的主題自動關閉，不再接受新回復
        let data = network.html(data: param)
        if isFirst {
            let regex = try! Regex("<a\\s*href=\"forum-\(fid)-1.html\">(.*?)</a>")
            if let first = regex.firstGroup(in: data.html) {
                log.debugPrint(text: "进入版块：\(first)「\(fid)」", type: .Info)
            }
        }
        let regex = try! Regex("<a\\s*href=\"forum.php\\?mod=viewthread&(amp;)*tid=(\\d{7,}).*?\"\\s*onclick=\"atarget\\(this\\)\"\\s*class=\".*?\"\\s*>(.*?)</a>")
        // 提取板块下所有的帖子id和名称
        let items = regex.matches(in: data.html).map { $0.captures.compactMap { $0 } }.filter { $0.count == 3 }.map { ($0[1], $0[2]) }.shuffled()
        // 板块内的贴子数(每个版块内最多回复3次)
        var forumReplyTime = 0
        for item in items {
            let comment = comments.randomElement()!
            if reply(comment: comment, fid: fid, tid: item.0, name: item.1) {
                forumReplyTime += 1
            }
            if forumReplyTime >= 3 || !user.canReply {
                break
            }
        }
        // 评论数不够15条时，获取另一批帖子
        forumList()
    }
    
    /// 发表评论
    /// - Parameters:
    ///   - comment: 评论内容
    ///   - fid: 版块id
    ///   - tid: 帖子id
    ///   - name: 帖子名称
    /// - Returns: 是否成功发表
    private func reply(comment: String, fid: Int, tid: String, name: String) -> Bool {
        let _url = PFConfig.default.fullURL("thread-\(tid)-1-1.html")
        log.debugPrint(text: "进入帖子->\(name)：\(_url)", type: .Info)
        // 发表评论前的金币数
        user.reloadMoney()
        var param = defaultData
        param.apiValue = ["fid": "\(fid)", "tid": tid]
        param.body = ["message": comment, "formhash": formhash, "posttime": "\(Int(Date().timeIntervalSince1970))"]
        param.type = .Reply
        let data = network.html(data: param)
        // 评论有时间间隔限制
        defer { waitSleep(type: .Reply) }
        if data.findSuccess(txt: "非常感謝，回復發佈成功") {
            user.replyTimes += 1
            log.debugPrint(text: "第\(user.replyTimes)条：「\(comment)」-> 發佈成功", type: .Success)
            if !user.reloadMoney() {
                // 如果发表评论后，金币数不增加，就不再发表评论
                log.print(text: "评论：\(user.replyTimes)，达到每日上限。不再发表评论。", type: .Warn)
                user.replyTimes += 1000
            }
            user.save()
            return true
        } else if data.findSuccess(txt: "抱歉，您所在的用戶組每小時限制發回帖") {
            log.print(text: "评论超过每小時限制数", type: .Warn)
            user.maxReplyTimes = user.replyTimes
            return true
        } else if data.findSuccess(txt: "主題自動關閉，不再接受新回復") {
            return false
        } else {
            log.print(texts: ["发表评论失败"] + data.errorData, type: .Faild)
            user.maxReplyFailTimes -= 1
            
            if !data.cdata.filter({ $0.contains("您目前處於見習期間") }).isEmpty {
                user.replyTimes = 888
                user.shareTimes = 888
                user.journalTimes = 888
                user.isLeaveMessage = false
                user.isRecord = false
                user.save()
            }
            return false
        }
    }
    
    /// 访问别人空间
    private func visitUserZone() {
        guard user.isVisitOtherZone else { return }
        if user.otherUserId > 999 {
            var param = defaultData
            param.apiValue = ["uid": "\(user.otherUserId)"]
            param.type = .Zone
            network.html(data: param, title: "访问别人空间")
            user.isVisitOtherZone = false
            user.save()
        } else {
            log.print(text: "别人id不存在，不能访问别人空间", type: .Faild)
        }
    }
    
    /// 留言
    private func leavMessage() {
        guard user.canLeaveMessage, user.otherUserId > 999 else { return }
        let refer = "home.php?mod=space&uid=\(user.otherUserId)"
        var param = defaultData
        param.body = ["refer": refer, "formhash": formhash, "id": "\(user.otherUserId)", "handlekey": "commentwall_\(user.otherUserId)", "message": "留个言，赚个金币。"]
        param.type = .LeavMessage
        let data = network.html(data: param)
        waitSleep(type: .LeaveMessage)
        if data.findSuccess() {
            log.debugPrint(text: "留言成功", type: .Success)
            user.isLeaveMessage = false
            user.save()
            let regex = try! Regex("\\{\\s*\\'cid\\'\\s*:\\s*\\'(\\d+)\\'\\s*\\}")
            if let id = regex.firstGroup(in: data.html) {
                deleteMessage(cId: id)
            }
        } else {
            log.print(texts: data.errorData, type: .Faild)
            if !data.cdata.filter({ $0.contains("您目前沒有權限進行評論") }).isEmpty {
                user.shareTimes = 888
                user.journalTimes = 888
                user.isLeaveMessage = false
                user.isRecord = false
                user.save()
                return
            }
            log.print(text: "留言失败", type: .Faild)
            user.maxLeaveMsgFailTimes -= 1
            if user.canLeaveMessage {
                leavMessage()
            } else {
                log.print(text: "发表留言失败,超过最大失败次数", type: .Faild)
            }
        }
    }
    
    /// 删除留言
    /// - Parameter cId: 留言id
    private func deleteMessage(cId: String) {
        let refer = PFNetwork.PFNetworkData(api: ["uid": "\(user.otherUserId)"], .Zone).url?.absoluteString ?? ""
        defaultData.header["Referer"] = refer
        var frontParam = defaultData
        frontParam.apiValue = ["cid": cId, "handlekey": "c_\(cId)_delete", "ajaxtarget": "fwin_content_c_\(cId)_delete"]
        frontParam.type = .DeleteMessageFront
        // 获取删除留言相关参数
        network.html(data: frontParam)
        // 请求删除留言
        var param = defaultData
        param.apiValue = ["cid": cId]
        param.body = ["handlekey": "c_\(cId)_delete", "formhash": formhash, "referer": refer]
        param.type = .DeleteMessage
        let data = network.html(data: param)
        if data.findSuccess() {
            log.debugPrint(text: "删除留言成功", type: .Success)
            waitSleep(type: .Other)
        } else {
            log.print(texts: data.errorData, type: .Faild)
            log.print(text: "删除留言失败", type: .Faild)
        }
    }
    
    /// 自己空间留言所产生的动态列表
    private func deleteAllleavMessageDynamic() {
        guard user.userId > 999 else { return }
        var param = defaultData
        param.apiValue = ["uid": "\(user.userId)"]
        param.type = .LeavMessageDynamicList
        let data = network.html(data: param)
        let regex = try! Regex("\"home.php\\?mod=spacecp&amp;ac=feed&amp;op=menu&amp;feedid=(\\d+)\"")
        let feedids = regex.matches(in: data.html).map { $0.captures.compactMap { $0 } }.flatMap { $0 }
        guard !feedids.isEmpty else { return }
        log.debugPrint(text: "\(feedids.count)条动态", type: .Success)
        let url = param.url?.absoluteString ?? ""
        feedids.forEach {
            deleteLeavMessageDynamic(feedid: $0, referer: url)
        }
    }
    
    /// 删除一条动态
    /// - Parameters:
    ///   - feedid: 动态的id
    ///   - referer: 来源地址
    private func deleteLeavMessageDynamic(feedid: String, referer: String) {
        guard !feedid.isEmpty, !referer.isEmpty else { return }
        defaultData.header["Referer"] = referer
        var frontParam = defaultData
        frontParam.apiValue = ["feedid": feedid, "handlekey": "a_feed_menu_\(feedid)", "ajaxtarget": "fwin_content_a_feed_menu_\(feedid)"]
        frontParam.type = .DeleteLeavMessageDynamicFront
        // 获取删除动态相关参数
        network.html(data: frontParam)
        
        // 删除动态
        var param = defaultData
        param.apiValue = ["feedid": feedid, "handlekey": "a_feed_menu_\(feedid)"]
        param.body = ["referer": referer, "formhash": formhash]
        param.type = .DeleteLeavMessageDynamic
        let data = network.html(data: param)
        if data.findSuccess() {
            log.debugPrint(text: "一条动态删除成功", type: .Success)
        } else {
            log.print(texts: data.errorData, type: .Faild)
            log.print(text: "删除动态失败", type: .Faild)
        }
    }
    
    /// 发表一条记录
    private func record() {
        guard user.canRecord, user.userId > 9999 else { return }
        let referer = "home.php?mod=space&uid=\(user.userId)&do=doing&view=me&from=space"
        let message = comments.randomElement()!
        var param = defaultData
        param.header["Referer"] = PFConfig.default.fullURL(referer)
        param.body = ["message": message, "formhash": formhash, "referer": referer]
        param.type = .Record
        let data = network.html(data: param)
        waitSleep(type: .Record)
        if data.findSuccess(txt: message) {
            log.debugPrint(text: "记录：「\(message)」-> 发表成功", type: .Success)
            user.isRecord = false
            user.save()
        } else {
            log.print(text: "发表记录失败", type: .Faild)
            user.maxRecordFailTimes -= 1
            if user.canRecord {
                record()
            } else {
                log.print(text: "发表记录失败，超过最大失败次数", type: .Faild)
            }
        }
    }
    
    /// 查询所有记录id
    private func findAllRecord() -> [String] {
        guard user.userId > 9999 else { return [] }
        var param = defaultData
        param.apiValue = ["uid": "\(user.userId)"]
        param.type = .FindAllRecord
        let html = network.html(data: param).html
        // group1: 标题，group2：id。筛选条件：标题是预设的评论内容
        let regex = try! Regex("<span>\\s*(.*?)\\s*</span>\\s*</dd>\\s*<dd\\s+class\\s*=\\s*\".*?\"\\s+id=\"(.*?)\"\\s+style\\s*=\\s*\"display:none;\"\\s*>", options: [.ignoreCase])
        let ids = regex.matches(in: html).map { $0.captures.compactMap { $0 } }.filter { $0.count == 2 && comments.contains($0[0]) }.map { $0[1] }
        return ids
    }
    
    /// 删除记录
    private func deleteRecord() {
        login()
        let ids = findAllRecord()
        guard !ids.isEmpty else { return }
        let referer = PFConfig.default.fullURL("home.php?mod=space&do=doing&view=me")
        for id in ids {
            let arr = id.components(separatedBy: "_")
            guard arr.count == 2 else { continue }
            let star = arr[0]
            let doid = arr[1]
            let handlekey = "\(star)_doing_delete_\(doid)_"
            var frontParam = defaultData
            frontParam.apiValue = ["doid": doid, "handlekey": handlekey, "ajaxtarget": "fwin_content_\(star)_doing_delete_\(doid)_"]
            frontParam.type = .DeleteRecordFront
            network.html(data: frontParam)
            
            var param = defaultData
            param.apiValue = ["doid": doid]
            param.body = ["handlekey": handlekey, "formhash": formhash, "referer": referer]
            param.type = .DeleteRecord
            network.html(data: param)
        }
    }
    
    /// 发表日志
    private func journal() {
        guard user.canJournal else { return }
        login()
        user.reloadMoney()
        let title = comments.randomElement()!
        let comment = comments.shuffled().suffix(10).joined(separator: "\n")
        let referer = PFConfig.default.fullURL("home.php?mod=space&uid=\(user.userId)&do=blog&view=me")
        let boundary = "----WebKitFormBoundary\(String.random(16))"
        var param = defaultData
        param.header["Referer"] = referer
        param.header["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        param.body = [
            "Boundary": boundary,
            "subject": "我的日志：\(title)",
            "savealbumid": "0",
            "newalbum": "請輸入相冊名稱",
            "view_albumid": "none",
            "message": comment,
            "formhash": formhash,
            "classid": "0",
            "tag": "",
            "friend": "0",
            "password": "",
            "selectgroup": "",
            "target_names": "",
            "blogsubmit": "true"
        ]
        param.type = .Journal
        let data = network.html(data: param)
        waitSleep(type: .Journal)
        if data.findSuccess(txt: title) {
            user.journalTimes += 1
            user.save()
            log.debugPrint(text: "第\(user.journalTimes)篇日志：「\(title)」-> 發佈成功", type: .Success)
            if !user.reloadMoney() {
                // 如果发表后，金币数不增加，就不再发表
                log.print(text: "日志:\(user.journalTimes)，达到每日上限。", type: .Warn)
                user.journalTimes += 1000
                user.save()
            }
        } else {
            user.maxJournalFailTimes -= 1
            log.print(text: "发表日志失败，准备重试。", type: .Faild)
        }
        
        // 发表有时间间隔限制
        if user.canJournal {
            journal()
        } else if user.maxJournalFailTimes <= 0 {
            log.print(text: "发表日志失败，超过最大失败次数。", type: .Faild)
        }
    }
    
    /// 查询自己所有脚本发表的日志
    private func allJournals() -> [String] {
        var param = defaultData
        param.apiValue = ["uid": "\(user.userId)"]
        param.type = .AllJournals
        let html = network.html(data: param).html
        let regex = try! Regex("<a\\s+href\\s*=\\s*\"blog-(\\d+)-(\\d+).html\"\\s+target\\s*=\\s*\"_blank\"\\s*>\\s*(.*?)\\s*</a>")
        let allBlogids = regex.matches(in: html).map { $0.captures.compactMap { $0 } }.filter { $0.count == 3 && $0[2].hasPrefix("我的日志") }.map { $0[1] }
        return allBlogids
    }
    
    /// 删除日志
    /// - Parameters:
    ///   - allBlogIds: 所有的日志id，为空自动获取
    ///   - delTimes: 删除次数（达到5次时，不再删除）
    private func delJournal(allBlogIds: [String]? = nil, delTimes: Int = 0) {
        guard delTimes < 5 else { return }
        var allIds = allBlogIds ?? allJournals()
        guard !allIds.isEmpty else { return }
        let id = allIds.removeFirst()
        login()
        let referer = PFConfig.default.fullURL("home.php?mod=space&do=blog&view=me")
        var param = defaultData
        param.apiValue = ["blogid": id]
        param.body = ["formhash": formhash, "referer": referer]
        param.type = .DelJournal
        network.html(data: param)
        waitSleep(type: .Other)
        let allBlogIds = allJournals()
        var times = delTimes
        if !allBlogIds.contains(id) {
            log.debugPrint(text: "日志删除成功:「\(id)」", type: .Success)
        } else {
            times += 1
            log.print(text: "日志删除失败:「\(id)」", type: .Faild)
        }
        guard !allBlogIds.isEmpty else { return }
        delJournal(allBlogIds: allBlogIds, delTimes: times)
    }
    
    /// 发布一个分享
    private func share() {
        guard user.canShare else { return }
        login()
        // 发表前的金币数
        user.reloadMoney()
        let referer = "home.php?mod=space&uid=\(user.userId)&do=share&view=me&quickforward=1"
        var param = defaultData
        param.header["Referer"] = PFConfig.default.fullURL(referer)
        param.body = ["formhash": formhash, "referer": referer, "link": "https://www.baidu.com", "general": comments.randomElement()!]
        param.type = .Share
        let data = network.html(data: param)
        waitSleep(type: .Share)
        if data.findSuccess() {
            user.shareTimes += 1
            user.save()
            if !user.reloadMoney() {
                // 如果发表后，金币数不增加，就不再发表
                log.print(text: "发表分享达到每日上限。", type: .Warn)
                user.shareTimes = 9999
                user.save()
            } else {
                log.debugPrint(text: "发布分享成功。", type: .Success)
            }
            // 删除刚发表的分享
            let regex = try! Regex("\\{\\s*\\'sid\\'\\s*:\\s*\\'(\\d+)\\'\\s*\\}", options: [.dotMatchesLineSeparators])
            if let sid = regex.firstGroup(in: data.html) {
                delShare(sid: sid)
            }
        } else {
            log.print(texts: ["发布分享失败"] + data.errorData, type: .Faild)
            user.maxShareFailTimes -= 1
            if !data.cdata.filter({ $0.contains("您目前沒有權限發佈分享") }).isEmpty {
                user.shareTimes = 888
                user.save()
            }
        }
        
        if user.canShare {
            share()
        } else if user.maxShareFailTimes <= 0 {
            log.print(text: "发布分享失败，超过最大失败次数。", type: .Faild)
        }
    }
    
    /// 删除一条分享
    /// - Parameter sid: 分享的id
    private func delShare(sid: String) {
        guard !sid.isEmpty else { return }
        let referer = PFConfig.default.fullURL("home.php?mod=space&do=share&view=me")
        var param = defaultData
        param.apiValue = ["sid": sid]
        param.body = ["formhash": formhash, "referer": referer, "handlekey": "s_\(sid)_delete"]
        param.type = .DeleteShare
        let data = network.html(data: param)
        if data.findSuccess() {
            log.debugPrint(text: "删除分享成功", type: .Success)
        } else {
            log.print(texts: data.errorData, type: .Faild)
            log.print(text: "删除分享失败", type: .Faild)
        }
    }
    
    /// 休息等待
    /// - Parameters:
    ///   - type: 休息类型
    private func waitSleep(type: PicType) {
        guard type.sleepSec > 0 else { return }
        sleepTime += type.sleepSec
        log.debugPrint(text: "\(type.rawValue)已发表，休息 \(type.sleepSec) 秒", type: .White)
        sleep(type.sleepSec)
    }
}
