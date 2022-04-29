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
    var headerFields: [String : String?]? = [
        "authority" : "www.hifini.com",
        "sec-ch-ua": " Not A;Brand\";v=\"99\", \"Chromium\";v=\"99\", \"Google Chrome\";v=\"99\"",
        "accept": "text/plain, */*; q=0.01",
        "dnt": "1",
        "sec-ch-ua-mobile":"?0",
        "user-agen":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.83 Safari/537.36",
        "sec-ch-ua-platform": "macOS",
        "origin": "https://www.hifini.com",
        "referer": "https://www.hifini.com/",
        "cookie": "bbs_sid=ieaslhc52jtv2nqrc0t7mlcikn; Hm_lvt_4ab5ca5f7f036f4a4747f1836fffe6f2=1650868388,1651024826; bbs_token=zR4Z0SXy0vsYq4QaPiz_2ByJFQyYvKHuy3zvWiY_2BcxA0gNvy_2Fk1usa1FDsJ5Vmfnx74fswEzIBpaxWJdNZqxTIq8EZJ9_2BXRjmm; Hm_lpvt_4ab5ca5f7f036f4a4747f1836fffe6f2=\(Int(Date().timeIntervalSince1970))"
    ]
    
    func run() {
        ATRequestManager.default.send(data: self) { result in
            self.finish()
        }
    }
}



/*
 
 class BWNetwork: NetworkData {
     
     static let `default` = BWNetwork()
     var host: String = "https://cn.bing.com"
     var api: String? = "HPImageArchive.aspx?format=js&idx=0&n=10&nc=1612409408851&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
     var headerFields: [String: String?]?  = ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"]
     
     /// 获取壁纸
     func getWallPaper(finish:(([String: Any]?)->Void)?) {
         ATRequestManager.default.send(data: self) { result in
             let json = result.data?.json as? [String: Any]
             finish?(json)
         }
     }
 }
 
 
 
 
 */
