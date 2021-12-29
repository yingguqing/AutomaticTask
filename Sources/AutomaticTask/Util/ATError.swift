//
//  ATError.swift
//  
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

enum ATError:Error, LocalizedError {
    case UnKnow
    case UrlInvalid
    case ParamsInvalid
    case ResultFaild
    case Status(msg:String)
    case Timeout
    case Error(_ error:Error)
    
    var code: Int {
        switch self {
            case .UnKnow:
                return -1
            case .UrlInvalid:
                return 100
            case .ParamsInvalid:
                return 200
            case .ResultFaild:
                return 300
            case .Status:
                return 700
            case .Timeout:
                return -1001
            case .Error(let error):
                let er = error as NSError
                return er.code
        }
    }
    
    var errorDescription: String {
        switch self {
            case .UnKnow:
                return "未知错误"
            case .UrlInvalid:
                return "URL无效"
            case .ParamsInvalid:
                return "参数不是字典，无效"
            case .ResultFaild:
                return "网络返回结果解析失败"
            case .Timeout:
                return "请求超时"
            case .Status(let msg):
                return msg
            case .Error(let error):
                return error.localizedDescription
        }
    }
    
    var localizedDescription: String {
        return self.errorDescription
    }
    
    init?(error:Error?) {
        if let error = error {
            let er = error as NSError
            if er.code == -1001 {
                self = .Timeout
            } else {
                self = ATError.Error(error)
            }
        } else {
            return nil
        }
    }
}
