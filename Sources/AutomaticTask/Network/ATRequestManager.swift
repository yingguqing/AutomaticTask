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
    // 拼接相应的cookie
    var cookies: String? { get }
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
    func finish() -> Bool
}

extension NetworkData {
    var cookies: String? {
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
        request.timeoutInterval = TimeInterval(15)
        request.httpMethod = method.rawValue
        if let cookies = cookies {
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
    class func asyncSend(data: NetworkData, complete: ((Data?, ATError?) -> Void)?) {
        guard let request = data.request else { return }
        dataTask(request: request, complete: complete)
    }
    
    /// 同步发送网络请求
    /// - Parameter data: 请求URL数据
    /// - Returns: (网络数据，错误)
    class func syncSend(data: NetworkData) -> (Data?, ATError?) {
        guard let request = data.request else { return (nil, nil) }
        return dataTask(request: request, isAsync: false, complete: nil)
    }

    /// 网络请求
    /// - Parameters:
    ///   - request: 请求的数据
    ///   - isUseCookie: 是否使用cookie
    ///   - isAsync: 是否使用异步请求
    ///   - complete: 回调
    @discardableResult private class func dataTask(request: URLRequest, isAsync: Bool = true, complete: ((Data?, ATError?) -> Void)?) -> (Data?, ATError?) {
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        var returnData: Data?
        var returnError: ATError?
        let task = session.dataTask(with: request) { data, response, error in
            if request.httpShouldHandleCookies, let url = response?.url, let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String] {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [HTTPCookiePropertyKey: Any]()
                    cookieProperties[.name] = cookie.name
                    cookieProperties[.value] = cookie.value
                    cookieProperties[.domain] = cookie.domain
                    cookieProperties[.path] = cookie.path
                    cookieProperties[.version] = cookie.version
                    cookieProperties[.expires] = Date().addingTimeInterval(31536000)

                    let newCookie = HTTPCookie(properties: cookieProperties)
                    HTTPCookieStorage.shared.setCookie(newCookie!)
                }
            }
            returnData = data
            returnError = ATError(error: error)
            complete?(data, ATError(error: error))
        }
        task.resume()
        if !isAsync {
            // 计算超时的最终时间戳
            let end = Date().timeIntervalSince1970 + request.timeoutInterval
            while returnData == nil && returnError == nil {
                RunLoop.current.run(mode: .default, before: .init(timeIntervalSinceNow: 1))
                if Date().timeIntervalSince1970 >= end {
                    returnError = .Timeout
                    task.cancel()
                    break
                }
            }
        }
        return (returnData, returnError)
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
