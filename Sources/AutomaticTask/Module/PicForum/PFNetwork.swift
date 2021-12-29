//
//  PFNetwork.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation
 #if canImport(FoundationNetworking)
 import FoundationNetworking
 #endif

struct PFResult {
    let html: String
    let error: ATError?
    let success: Bool
    
    init(html: String) {
        self.html = html
        self.error = nil
        self.success = true
    }
    
    init(error: ATError?) {
        self.error = error
        self.html = ""
        self.success = false
    }
    
    var cdata: [String] {
        let regex = try! Regex("\\[CDATA\\[(.*?)<", options: [.ignoreCase])
        let item = regex.matches(in: html).map { $0.captures.compactMap { $0 } }.flatMap { $0 }
        return item
    }
    
    var errorData: [String] {
        return cdata.isEmpty ? [html] : cdata
    }
    
    func findSuccess(txt: String = "操作成功") -> Bool {
        return html.contains(txt)
    }
}

class PFNetwork {
    fileprivate static let `default` = PFNetwork()
    lazy var requestManager = ATRequestManager()
    // 请求用到的cookie
    var cookies = [HTTPCookie]()
    
    struct PFNetworkData: NetworkData {
        static let defaultHeader = [
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
            "Accept-Encoding": "gzip, deflate",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 GDMobile/8.0.4",
            "Content-Type": "application/x-www-form-urlencoded",
            "Origin": PFConfig.default.host,
            "Cache-Control": "max-age=0",
            "DNT": "1",
            "Proxy-Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
            "Referer": PFConfig.default.fullURL(PFNetwork.API.Home.api)
        ]
        
        let host: String = PFConfig.default.host
        var header: [String: String]
        var apiValue: [String: String]
        var body: [String: String]
        var type: API = .Home
        var cookies: [HTTPCookie]
        
        init(header: [String: String] = [:], api: [String: String] = [:], body: [String: String] = [:], _ type: API) {
            self.header = header
            self.apiValue = api
            self.body = body
            self.type = type
            self.cookies = []
        }
        
        var headerFields: [String: String?]? {
            return header
        }
        
        var api: String {
            let apiString = type.api
            if type == .Zone {
                let userId = apiValue["uid"] ?? ""
                return String(format: apiString, userId)
            } else {
                return apiString.urlAppend(params: apiValue)
            }
        }
        
        var bodyData: Data? {
            let params: String
            if type == .Journal {
                let boundary = body["Boundary"] ?? ""
                var args = body.filter { $0.0 != "Boundary" }.map { "--\(boundary)\r\nContent-Disposition: form-data; name=\"\($0.0)\"\r\n\r\n\($0.1)\r\n" }
                args.append("--\(boundary)--")
                params = args.joined().replacingOccurrences(of: "'", with: "\"")
            } else if let bodyString = type.body {
                params = bodyString.urlAppend(params: body)
            } else {
                return nil
            }
            return params.data(using: .utf8)
        }
        
        var method: HttpMethod {
            let getAPI: [API] = [.Home, .Zone, .ForumList, .DeleteMessageFront, .LeavMessageDynamicList, .DeleteLeavMessageDynamicFront, .FindAllRecord, .DeleteRecordFront, .AllJournals]
            return getAPI.contains(type) ? .GET : .POST
        }
        
        func updateCookies(_ cookies: [HTTPCookie]) -> PFNetworkData {
            var data = self
            data.cookies = cookies
            return data
        }
        
        var cookieString: String? {
            guard type != .Login else {
                // 登录时，自动清除cookies
                return nil
            }
            let cookieString = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            return cookieString
        }
    }
    
    enum API: String {
        /// 首页
        case Home = "首页"
        /// 登录
        case Login = "登录"
        /// 签到
        case SignIn = "签到"
        /// 空间
        case Zone = "空间"
        /// 版块帖子列表
        case ForumList = "版块帖子列表"
        /// 发表评论
        case Reply = "发表评论"
        /// 留言
        case LeavMessage = "留言"
        /// 删除留言前
        case DeleteMessageFront = "删除留言前"
        /// 删除留言
        case DeleteMessage = "删除留言"
        /// 自己空间留言所产生的动态列表
        case LeavMessageDynamicList = "自己空间留言所产生的动态列表"
        /// 删除动态前
        case DeleteLeavMessageDynamicFront = "删除动态前"
        /// 删除动态
        case DeleteLeavMessageDynamic = "删除动态"
        /// 发表记录
        case Record = "发表记录"
        /// 查询所有记录
        case FindAllRecord = "查询所有记录"
        /// 删除记录前
        case DeleteRecordFront = "删除记录前"
        /// 删除记录
        case DeleteRecord = "删除记录"
        /// 发表日志
        case Journal = "发表日志"
        /// 所有日志
        case AllJournals = "所有日志"
        /// 删除日志
        case DelJournal = "删除日志"
        /// 发布分享
        case Share = "发布分享"
        /// 删除分享
        case DeleteShare = "删除分享"
        
        var api: String {
            switch self {
                case .Home:
                    return "forum.php"
                case .Login:
                    return "member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1"
                case .SignIn:
                    return "plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&sign_as=1&inajax=1"
                case .Zone:
                    return "space-uid-%@.html"
                case .ForumList:
                    return "forum.php?mod=forumdisplay&filter=author&orderby=dateline"
                case .Reply:
                    return "forum.php?mod=post&action=reply&extra=page%3D1&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1"
                case .LeavMessage:
                    return "home.php?mod=spacecp&ac=comment&inajax=1"
                case .DeleteMessageFront:
                    return "home.php?mod=spacecp&ac=comment&op=delete&infloat=yes&inajax=1"
                case .DeleteMessage:
                    return "home.php?mod=spacecp&ac=comment&op=delete&inajax=1"
                case .LeavMessageDynamicList:
                    return "home.php?mod=space&do=home&view=me&from=space"
                case .DeleteLeavMessageDynamicFront:
                    return "home.php?mod=spacecp&ac=feed&op=menu&infloat=yes&inajax=1"
                case .DeleteLeavMessageDynamic:
                    return "home.php?mod=spacecp&ac=feed&op=delete&inajax=1"
                case .Record:
                    return "home.php?mod=spacecp&ac=doing&view=me"
                case .FindAllRecord:
                    return "home.php?mod=space&do=doing&view=me&from=space"
                case .DeleteRecordFront:
                    return "home.php?mod=spacecp&ac=doing&op=delete&id=&infloat=yes&inajax=1"
                case .DeleteRecord:
                    return "home.php?mod=spacecp&ac=doing&op=delete&id=0"
                case .Journal:
                    return "home.php?mod=spacecp&ac=blog&blogid="
                case .AllJournals:
                    return "home.php?mod=space&do=blog&view=me&from=space"
                case .DelJournal:
                    return "home.php?mod=spacecp&ac=blog&op=delete"
                case .Share:
                    return "home.php?mod=spacecp&ac=share&type=link&view=me&from=&inajax=1"
                case .DeleteShare:
                    return "home.php?mod=spacecp&ac=share&op=delete&type=&inajax=1"
            }
        }
        
        var body: String? {
            switch self {
                case .Login:
                    return "fastloginfield=username&cookietime=2592000&quickforward=yes&handlekey=ls"
                case .SignIn:
                    return "qdxq=kx"
                case .Reply:
                    return "usesig=1&subject=++"
                case .LeavMessage:
                    return "idtype=uid&commentsubmit=true"
                case .DeleteMessage:
                    return "deletesubmit=true"
                case .DeleteLeavMessageDynamic:
                    return "feedsubmit=true"
                case .Record:
                    return "add=&topicid=&addsubmit=true"
                case .DeleteRecord:
                    return "deletesubmit=true"
                case .DelJournal:
                    return "btnsubmit=true&deletesubmit=true"
                case .Share:
                    return "handlekey=shareadd&sharesubmit=true"
                case .DeleteShare:
                    return "deletesubmit=true"
                default:
                    return nil
            }
        }
    }
}

extension PFNetwork {
    // MARK: 接口
    
    /// 访问html
    /// - Parameters:
    ///   - data: 相应地址
    ///   - title: 标题
    ///   - isCleanCookie: 是否清除所有cookie
    ///   - failTimes: 失败次数
    @discardableResult func html(data: PFNetworkData, title: String = "", failTimes: Int = 0) -> PFResult {
        // 更新cookies
        let param = data.updateCookies(cookies)
        let resultData = requestManager.syncSend(data: param)
        let htmlString = resultData.data?.text
        if htmlString?.contains("400 Bad Request") == true, failTimes < 5 {
            return html(data: data, title: title, failTimes: failTimes + 1)
        } else if let htmlString = htmlString {
            updateCookies(resultData.cookies)
            return PFResult(html: htmlString)
        } else if resultData.error?.code == ATError.Timeout.code, failTimes < 5 {
            return html(data: data, title: title, failTimes: failTimes + 1)
        } else {
            print("\(title.isEmpty ? data.type.rawValue : title)失败：\(resultData.error?.localizedDescription ?? "")")
            return PFResult(error: resultData.error)
        }
    }
    
    /// 获取用户金币数
    /// - Parameters:
    ///   - id: 用户id
    ///   - complete: 回调
    class func userMoney(id: Int) -> Int {
        guard id > 999 else { return -1 }
        let netData = PFNetworkData(header: PFNetworkData.defaultHeader, api: ["uid": "\(id)"], .Zone)
        let data = PFNetwork.default.html(data: netData)
        let regex = try! Regex("<li>金錢:\\s*<a href=\".*?\">(\\d+)</a>", options: [.ignoreCase])
        if let money = Int(regex.firstGroup(in: data.html) ?? "") {
            return money
        }
        print("获取金币失败：\(data.error?.localizedDescription ?? "")--\(netData.url?.absoluteString ?? "")")
        return -1
    }
    
    /// 更新Cookies
    /// - Parameter cookies: 新cookies
    func updateCookies(_ cookies: [HTTPCookie]) {
        // 删除同名的cookie，保留最新的
        var newCookies = self.cookies + cookies
        var names = Set<String>()
        var removeIndex = [Int]()
        for (index, value) in newCookies.enumerated() {
            if names.contains(value.name) {
                removeIndex.append(index)
            } else {
                names.insert(value.name)
            }
        }
        removeIndex.reversed().forEach({ newCookies.remove(at: $0) })
        self.cookies = newCookies
    }
}
