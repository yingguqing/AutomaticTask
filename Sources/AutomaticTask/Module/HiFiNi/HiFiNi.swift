//
//  HiFiNi.swift
//  AutomaticTask
//
//  Created by zhouziyuan on 2022/4/29.
//

import Foundation

// 音乐磁场签到 有ip限制，github的action被限制
class HiFiNi: ATBaseTask, NetworkData {
    var host: String = "https://www.hifini.com/sg_sign.htm"
    var api: String? = nil
    let sid: String
    let token:String
    let uid:String
    var method: HttpMethod = .POST
    lazy var headerFields: [String : String?]? = [
        "X-Requested-With" : "XMLHttpRequest"
    ]
    
    var cookieString: String? {
        let ts = String(Int(Date().timeIntervalSince1970))
        let cookies = [
            "bbs_sid":sid,
            "Hm_lvt_\(uid)": ts,
            "bbs_token": token,
            "Hm_lpvt_\(uid)": ts
        ]
        return cookies.map { "\($0.0)=\($0.1)" }.joined(separator: "; ")
    }
    
    init(json:[String:String]) {
        self.sid = json.value(key: "sid", defaultValue: "")
        self.token = json.value(key: "token", defaultValue: "")
        self.uid = json.value(key: "uid", defaultValue: "")
    }
    
    func run(isDebug:Bool) {
        let log = ATPrintLog(title: "音乐磁场")
        log.isDebug = isDebug
        ATRequestManager.default.send(data: self) { result in
            let msg:String
            if let json = result.data?.json as? [String:String] {
                msg = json["message"] ?? result.data?.text ?? "数据错误"
            } else {
                msg = result.data?.text ?? "网络错误"
            }
            log.print(text: msg, type: .Success)
            log.printLog()
            self.finish()
        }
    }
}

