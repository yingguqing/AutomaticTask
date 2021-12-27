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

class ATRequestManager {
    private init() {}
    
    /// 异步发送网络请求
    /// - Parameters:
    ///   - data: 请求URL数据
    ///   - complete: 完成回调
    class func asyncSend(data: NetworkData, complete: ((Data?, [String:String], ATError?) -> Void)?) {
        dataTask(netData: data, complete: complete)
    }
    
    /// 同步发送网络请求
    /// - Parameter data: 请求URL数据
    /// - Returns: (网络数据，错误)
    class func syncSend(data: NetworkData) -> (Data?, [String:String], ATError?) {
        return dataTask(netData: data, isAsync: false, complete: nil)
    }

    /// 网络请求
    /// - Parameters:
    ///   - request: 请求的数据
    ///   - isUseCookie: 是否使用cookie
    ///   - isAsync: 是否使用异步请求
    ///   - complete: 回调
    @discardableResult private class func dataTask(netData: NetworkData, isAsync: Bool = true, complete: ((Data?, [String:String], ATError?) -> Void)?) -> (Data?, [String:String], ATError?) {
        guard let request = netData.request else { return (nil, [:], nil) }
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        var returnData: Data?
        var returnError: ATError?
        var cookieDic = [String:String]()
        let task = session.dataTask(with: request) { data, response, error in
            if request.httpShouldHandleCookies, let url = response?.url, let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                cookies.forEach {
                    cookieDic[$0.name] = $0.value
                }
            }
            returnData = data
            returnError = ATError(error: error)
            complete?(data, cookieDic, returnError)
        }
        task.resume()
        // 同步请求
        guard !isAsync else { return (returnData, cookieDic, returnError) }
        // 计算超时的最终时间戳
        let end = Date().timeIntervalSince1970 + request.timeoutInterval + 5
        while returnData == nil && returnError == nil {
            _ = RunLoop.current.run(mode: .default, before: .init(timeIntervalSinceNow: 1))
            if Date().timeIntervalSince1970 >= end {
                returnError = .Timeout
                task.cancel()
                break
            }
        }
        return (returnData, cookieDic, returnError)
    }

    /// 清除所有cookie
    class func cleanCookie(url: URL?) {
        guard let url = url else {
            return
        }

        HTTPCookieStorage.shared.cookies(for: url)?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
    }
}
