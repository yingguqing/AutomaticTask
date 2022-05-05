//
//  HiFiNi.swift
//  AutomaticTask
//
//  Created by zhouziyuan on 2022/4/29.
//

import Foundation

// 音乐磁场签到
class HiFiNi: ATBaseTask, NetworkData {
    var host: String = "https://www.hifini.com/sg_sign.htm"
    var api: String? = nil
    let sid: String
    let token:String
    let uid:String
    // 签到的所有日期时间戳
    var lvt:[String] = []
    lazy var headerFields: [String : String?]? = [
        "authority" : "www.hifini.com",
        "sec-ch-ua": " Not A;Brand\";v=\"99\", \"Chromium\";v=\"99\", \"Google Chrome\";v=\"99\"",
        "accept": "text/plain, */*; q=0.01",
        "dnt": "1",
        "sec-ch-ua-mobile":"?0",
        "user-agen":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36",
        "sec-ch-ua-platform": "macOS",
        "origin": "https://www.hifini.com",
        "referer": "https://www.hifini.com/"
    ]
    
    var cookieString: String? {
        let ts = String(Int(Date().timeIntervalSince1970))
        self.lvt.append(ts)
        let cookies = [
            "bbs_sid":sid,
            "Hm_lvt_\(uid)": self.lvt.joined(separator: ","),
            "bbs_token": token,
            "Hm_lpvt_\(uid)": ts
        ]
        return cookies.map { "\($0.0)=\($0.1)" }.joined(separator: "; ")
    }
    
    init(json:[String:String]) {
        self.sid = json.value(key: "sid", defaultValue: "")
        self.token = json.value(key: "token", defaultValue: "")
        self.uid = json.value(key: "uid", defaultValue: "")
        self.lvt = ATConfig.default.read(key: "HiFiNi") as? [String] ?? []
    }
    
    func run(isDebug:Bool) {
        let log = ATPrintLog(title: "音乐磁场")
        log.isDebug = isDebug
        ATRequestManager.default.send(data: self) { result in
            if isDebug {
                log.print(text: result.data?.text ?? "数据错误", type: .Success)
            }
            ATConfig.default.save(key: "HiFiNi", value: self.lvt)
            self.finish()
        }
    }
}

