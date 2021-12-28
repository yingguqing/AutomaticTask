//
//  BWNetwork.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

class BWNetwork {
    
    enum API: NetworkData {
        case HPImageArchive
        
        var host: String {
            return "https://cn.bing.com"
        }
        
        var api: String {
            switch self {
                case .HPImageArchive:
                    let param = [
                        "format": "js",
                        "idx": "0",
                        "n": "10",
                        "nc": "1612409408851",
                        "pid": "hp",
                        "FORM": "BEHPTB",
                        "uhd": "1",
                        "uhdwidth": "3840",
                        "uhdheight": "2160"
                    ]
                    return "HPImageArchive.aspx?".urlAppend(params: param)
            }
        }
        
        var method: HttpMethod {
            switch self {
                case .HPImageArchive:
                    return .GET
            }
        }
        
        var headerFields: [String: String?]? {
            return ["User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"]
        }
    }
    
    /// 获取壁纸
    class func getWallPaper(finish:(([String: Any]?)->Void)?) {
        ATRequestManager.default.asyncSend(data: API.HPImageArchive) { result in
            let json = result.data?.json as? [String: Any]
            finish?(json)
        }
    }
}

