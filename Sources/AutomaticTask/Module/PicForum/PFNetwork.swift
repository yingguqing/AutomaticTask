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
    private init() {}
    
    struct APIData {
        let header: [String: String]
        let api: [String: String]
        let body: [String: String]
        
        init(header: [String: String] = [:], api: [String: String] = [:], body: [String: String] = [:]) {
            self.header = header
            self.api = api
            self.body = body
        }
    }
    
    // MARK: API
    
    enum API: NetworkData {
        /// 首页
        case Home
        /// 登录
        case Login(_ param: APIData)
        /// 签到
        case SignIn(_ param: APIData)
        /// 空间
        case Zone(id: Int)
        /// 版块帖子列表
        case ForumList(_ param: APIData)
        /// 发表评论
        case Reply(_ param: APIData)
        /// 留言
        case LeavMessage(_ param: APIData)
        /// 删除留言前
        case DeleteMessageFront(_ param: APIData)
        /// 删除留言前
        case DeleteMessage(_ param: APIData)
        /// 自己空间留言所产生的动态列表
        case LeavMessageDynamicList(_ param: APIData)
        /// 删除动态前
        case DeleteLeavMessageDynamicFront(_ param: APIData)
        /// 删除动态
        case DeleteLeavMessageDynamic(_ param: APIData)
        /// 发表记录
        case Record(_ param: APIData)
        /// 查询所有记录
        case FindAllRecord(_ param: APIData)
        /// 删除记录前
        case DeleteRecordFront(_ param: APIData)
        /// 删除记录
        case DeleteRecord(_ param: APIData)
        /// 发表日志
        case Journal(_ param: APIData)
        /// 所有日志
        case AllJournals(_ param: APIData)
        /// 删除日志
        case DelJournal(_ param: APIData)
        /// 表布分享前
        case ShareFront(_ param: APIData)
        /// 表布分享
        case Share(_ param: APIData)
        /// 删除分享
        case DeleteShare(_ param: APIData)
        
        var host: String {
            return PFConfig.default.host
        }
        
        var title: String {
            switch self {
                case .Home:
                    return "首页"
                case .Login:
                    return "登录"
                case .SignIn:
                    return "签到"
                case .Zone:
                    return "空间"
                case .ForumList:
                    return "版块帖子列表"
                case .Reply:
                    return "发表评论"
                case .LeavMessage:
                    return "留言"
                case .DeleteMessageFront:
                    return "删除留言前"
                case .DeleteMessage:
                    return "删除留言前"
                case .LeavMessageDynamicList:
                    return "自己空间留言所产生的动态列表"
                case .DeleteLeavMessageDynamicFront:
                    return "删除动态前"
                case .DeleteLeavMessageDynamic:
                    return "删除动态"
                case .Record:
                    return "发表记录"
                case .FindAllRecord:
                    return "查询所有记录"
                case .DeleteRecordFront:
                    return "删除记录前"
                case .DeleteRecord:
                    return "删除记录"
                case .Journal:
                    return "发表日志"
                case .AllJournals:
                    return "所有日志"
                case .DelJournal:
                    return "删除日志"
                case .ShareFront:
                    return "表布分享前"
                case .Share:
                    return "表布分享"
                case .DeleteShare:
                    return "删除分享"
            }
        }
        
        var api: String {
            switch self {
                case .Home:
                    return "forum.php"
                case .Login:
                    return "member.php?mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1"
                case .SignIn:
                    return "plugin.php?id=dsu_paulsign:sign&operation=qiandao&infloat=1&sign_as=1&inajax=1"
                case .Zone(let id):
                    return "space-uid-\(id).html"
                case .ForumList(let param):
                    return "forum.php?mod=forumdisplay&filter=author&orderby=dateline".urlAppend(params: param.api)
                case .Reply(let param):
                    return "forum.php?mod=post&action=reply&extra=page%3D1&replysubmit=yes&infloat=yes&handlekey=fastpost&inajax=1".urlAppend(params: param.api)
                case .LeavMessage:
                    return "home.php?mod=spacecp&ac=comment&inajax=1"
                case .DeleteMessageFront(let param):
                    // delcommenthk_\(cid)
                    return "home.php?mod=spacecp&ac=comment&op=delete&infloat=yes&inajax=1".urlAppend(params: param.api)
                case .DeleteMessage(let param):
                    return "home.php?mod=spacecp&ac=comment&op=delete&inajax=1".urlAppend(params: param.api)
                case .LeavMessageDynamicList(let param):
                    return "home.php?mod=space&do=home&view=me&from=space".urlAppend(params: param.api)
                case .DeleteLeavMessageDynamicFront(let param):
                    return "home.php?mod=spacecp&ac=feed&op=menu&infloat=yes&inajax=1".urlAppend(params: param.api)
                case .DeleteLeavMessageDynamic(let param):
                    return "home.php?mod=spacecp&ac=feed&op=delete&inajax=1".urlAppend(params: param.api)
                case .Record:
                    return "home.php?mod=spacecp&ac=doing&view=me"
                case .FindAllRecord(let param):
                    return "home.php?mod=space&do=doing&view=me&from=space".urlAppend(params: param.api)
                case .DeleteRecordFront(let param):
                    // handlekey=doinghk_\(doid)_
                    return "home.php?mod=spacecp&ac=doing&op=delete&id=&infloat=yes&inajax=1".urlAppend(params: param.api)
                case .DeleteRecord(let param):
                    return "home.php?mod=spacecp&ac=doing&op=delete&id=0".urlAppend(params: param.api)
                case .Journal:
                    return "home.php?mod=spacecp&ac=blog&blogid="
                case .AllJournals(let param):
                    return "home.php?mod=space&do=blog&view=me&from=space".urlAppend(params: param.api)
                case .DelJournal(let param):
                    return "home.php?mod=spacecp&ac=blog&op=delete".urlAppend(params: param.api)
                case .ShareFront(let param):
                    return "home.php?mod=space&do=share&view=me&quickforward=1".urlAppend(params: param.api)
                case .Share:
                    return "home.php?mod=spacecp&ac=share&type=link&view=me&from=&inajax=1"
                case .DeleteShare(let param):
                    return "home.php?mod=spacecp&ac=share&op=delete&type=&inajax=1".urlAppend(params: param.api)
            }
        }
        
        var method: HttpMethod {
            switch self {
                case .Home,
                     .Zone,
                     .ForumList,
                     .DeleteMessageFront,
                     .LeavMessageDynamicList,
                     .DeleteLeavMessageDynamicFront,
                     .FindAllRecord,
                     .DeleteRecordFront,
                     .AllJournals,
                     .ShareFront:
                    return .GET
                case .Login,
                     .SignIn,
                     .Reply,
                     .LeavMessage,
                     .DeleteMessage,
                     .DeleteLeavMessageDynamic,
                     .Record,
                     .DeleteRecord,
                     .Journal,
                     .DelJournal,
                     .Share,
                     .DeleteShare:
                    return .POST
            }
        }
        
        var cookies: String? {
            guard let url = self.url, let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return "" }
            let cookieString = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            return cookieString
        }
        
        var headerFields: [String: String?]? {
            var headers = [
                "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                "Accept-Encoding": "gzip, deflate",
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 GDMobile/8.0.4",
                "Content-Type": "application/x-www-form-urlencoded",
                "Origin": self.host,
                "Cache-Control": "max-age=0",
                "DNT": "1",
                "Proxy-Connection": "keep-alive",
                "Upgrade-Insecure-Requests": "1",
                "Referer": API.Home.url?.absoluteString ?? ""
            ]
            switch self {
                case .DeleteMessageFront(let param):
                    headers.merge(param.header) { _, new in new }
                case .DeleteLeavMessageDynamicFront(let param):
                    headers.merge(param.header) { _, new in new }
                case .Record(let param):
                    if let referer = param.header["Referer"] {
                        headers["Referer"] = PFConfig.default.fullURL(referer)
                    }
                case .Journal(let param):
                    if let referer = param.header["Referer"] {
                        headers["Referer"] = referer
                    }
                    if let boundary = param.header["Boundary"] {
                        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
                    }
                case .Share(let param):
                    if let referer = param.header["Referer"] {
                        headers["Referer"] = PFConfig.default.fullURL(referer)
                    }
                default:
                    break
            }
            return headers
        }
        
        var bodyData: Data? {
            let params: String
            switch self {
                case .Login(let param):
                    params = "fastloginfield=username&cookietime=2592000&quickforward=yes&handlekey=ls".urlAppend(params: param.body)
                case .SignIn(let param):
                    params = "qdxq=kx".urlAppend(params: param.body)
                case .Reply(let param):
                    params = "usesig=1&subject=++".urlAppend(params: param.body)
                case .LeavMessage(let param):
                    params = "idtype=uid&commentsubmit=true".urlAppend(params: param.body)
                case .DeleteMessage(let param):
                    params = "deletesubmit=true".urlAppend(params: param.body)
                case .DeleteLeavMessageDynamic(let param):
                    params = "feedsubmit=true".urlAppend(params: param.body)
                case .Record(let param):
                    params = "add=&topicid=&addsubmit=true".urlAppend(params: param.body)
                case .DeleteRecord(let param):
                    params = "deletesubmit=true".urlAppend(params: param.body)
                case .Journal(let param):
                    let boundary = param.header["Boundary"] ?? ""
                    var args = param.body.map { "--\(boundary)\r\nContent-Disposition: form-data; name=\"\($0.0)\"\r\n\r\n\($0.1)\r\n" }
                    args.append("--\(boundary)--")
                    params = args.joined().replacingOccurrences(of: "'", with: "\"")
                case .DelJournal(let param):
                    params = "btnsubmit=true&deletesubmit=true".urlAppend(params: param.body)
                case .Share(let param):
                    params = "handlekey=shareadd&sharesubmit=true".urlAppend(params: param.body)
                case .DeleteShare(let param):
                    params = "deletesubmit=true".urlAppend(params: param.body)
                default:
                    return nil
            }
            return params.data(using: .utf8)
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
    @discardableResult class func html(data: API, title: String = "", isCleanCookie: Bool = false, failTimes: Int = 0) -> PFResult {
        if isCleanCookie {
            ATRequestManager.cleanCookie(url: data.url)
        }
        // print(data.url?.absoluteString)
        let resultData = ATRequestManager.syncSend(data: data)
        if let htmlString = resultData.0?.text {
            if let _ = htmlString.range(of: "404 Not Found") {
                print(data.url?.absoluteString ?? "")
            }
            if let _ = htmlString.range(of: "400 Bad Request"), failTimes < 5 {
                print("400 Bad Request")
                return html(data: data, title: title, isCleanCookie: isCleanCookie, failTimes: failTimes + 1)
            }
            return PFResult(html: htmlString)
        } else {
            print("\(title.isEmpty ? data.title : title)失败：\(resultData.1?.localizedDescription ?? "")")
            return PFResult(error: resultData.1)
        }
    }
    
    /// 获取用户金币数
    /// - Parameters:
    ///   - id: 用户id
    ///   - complete: 回调
    class func userMoney(id: Int) -> Int {
        guard id > 999 else { return -1 }
        let data = ATRequestManager.syncSend(data: API.Zone(id: id))
        if let html = data.0?.text {
            let regex = try! Regex("<li>金錢:\\s*<a href=\".*?\">(\\d+)</a>", options: [.ignoreCase])
            return Int(regex.firstGroup(in: html) ?? "") ?? -1
        }
        print("获取金币失败：\(data.1?.localizedDescription ?? "")")
        return -1
    }
}
