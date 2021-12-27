//
//  RequestManager.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// 请求类型
enum HttpMethod: String {
    case POST
    case GET
}

protocol NetworkData {
    // 域名
    var host: String { get }
    // 请求api
    var api: String { get }
    // 具体的url
    var url: URL? { get }
    // cookie拼接成相应的样式
    var cookieString:String? { get }
    // 请求头参数
    var headerFields: [String: String?]? { get }
    // 请求bodyData
    var bodyData: Data? { get }
    // 请求方式
    var method: HttpMethod { get }
    // 请求request
    var request: URLRequest? { get }
}

protocol AutomaticTask {
    var timeout:Int { get }
    func isFinish() -> Bool
}

extension NetworkData {
    var cookieString: String? {
        return nil
    }

    var headerFields: [String: String?]? {
        return nil
    }

    var bodyData: Data? {
        return nil
    }

    var url: URL? {
        var string = host
        if string.hasSuffix("/"), api.hasPrefix("?") {
            string = String(string.dropLast())
        }
        return URL(string: string.urlAppendPathComponent(api))
    }

    /// 请求request
    var request: URLRequest? {
        guard let url = self.url else { return nil }
        var request = URLRequest(url: url)
        // 设置超时时间
        request.timeoutInterval = TimeInterval(60)
        request.httpMethod = method.rawValue
        if let cookies = cookieString {
            request.httpShouldHandleCookies = true
            request.setValue(cookies, forHTTPHeaderField: "Cookie")
        }
        // 请求头参数
        headerFields?.forEach {
            request.setValue($0.1, forHTTPHeaderField: $0.0)
        }
        request.httpBody = bodyData
        return request
    }
}

struct ATResult {
    let data:Data?
    var cookies:[String:String]
    let error:ATError?
    
    static let nilValue:ATResult = ATResult(data: nil, cookies: [:], error: nil)
    
    init(data:Data?, cookies:[String:String]=[:], error:ATError?) {
        self.data = data
        self.cookies = cookies
        self.error = error
    }
    
}

class ATRequestManager {
    private init() {}
    
    /// 异步发送网络请求
    /// - Parameters:
    ///   - data: 请求URL数据
    ///   - complete: 完成回调
    class func asyncSend(data: NetworkData, complete: ((ATResult) -> Void)?) {
        dataTask(netData: data, complete: complete)
    }
    
    /// 同步发送网络请求
    /// - Parameter data: 请求URL数据
    /// - Returns: (网络数据，错误)
    class func syncSend(data: NetworkData) -> ATResult {
        return dataTask(netData: data, isAsync: false, complete: nil)
    }

    /// 网络请求
    /// - Parameters:
    ///   - request: 请求的数据
    ///   - isUseCookie: 是否使用cookie
    ///   - isAsync: 是否使用异步请求
    ///   - complete: 回调
    @discardableResult private class func dataTask(netData: NetworkData, isAsync: Bool = true, complete: ((ATResult) -> Void)?) -> ATResult {
        guard let request = netData.request else { return ATResult.nilValue }
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        var returnResult:ATResult?
        let task = session.dataTask(with: request) { data, response, error in
            var result = ATResult(data: data, error: ATError(error: error))
            if request.httpShouldHandleCookies, let url = response?.url, let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                cookies.forEach {
                    result.cookies[$0.name] = $0.value
                }
            }
            if isAsync {
                complete?(result)
            } else {
                returnResult = result
            }
            
        }
        task.resume()
        // 同步请求
        guard !isAsync else { return ATResult.nilValue }
        // 计算超时的最终时间戳
        let end = Date().timeIntervalSince1970 + request.timeoutInterval + 5
        while returnResult == nil {
            _ = RunLoop.current.run(mode: .default, before: .init(timeIntervalSinceNow: 1))
            if Date().timeIntervalSince1970 >= end {
                returnResult = ATResult(data: nil, error: .Timeout)
                task.cancel()
                break
            }
        }
        return returnResult!
    }
}
