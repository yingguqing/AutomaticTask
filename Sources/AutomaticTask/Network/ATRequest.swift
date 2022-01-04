//
//  ATURLRequest.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

class ATRequest: URLRequest {
    // 重试次数，如果不需要重试，就设置成0
    var retryTimes:Int = 5

    // 如果可以重试，就返回重试请求
    var retry:ATRequest? {
        guard retryTimes > 0 else { return nil }
        retryTimes -= 1
        return self
    }
}