//
//  BWNetwork.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

class BWNetwork: NetworkData {
    static let `default` = BWNetwork()
    var host: String = "https://cn.bing.com"
    var api: String? = "HPImageArchive.aspx?format=js&idx=0&n=10&nc=1612409408851&pid=hp&FORM=BEHPTB&uhd=1&uhdwidth=3840&uhdheight=2160"
    var headerFields: [String: String?]? = ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"]

    /// 获取壁纸
    func getWallPaper() async -> [String: Any]? {
        let result = await ATRequestManager.default.send(data: self)
        let json = result.data?.json as? [String: Any]
        return json
    }
}
