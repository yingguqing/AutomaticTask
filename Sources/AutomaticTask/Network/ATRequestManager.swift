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
    var api: String? { get }
    // 具体的url
    var url: URL? { get }
    // cookie拼接成相应的样式
    var cookieString: String? { get }
    // 请求头参数
    var headerFields: [String: String?]? { get }
    // 请求bodyData
    var bodyData: Data? { get }
    // 请求方式
    var method: HttpMethod { get }
    // 请求request
    var request: URLRequest? { get }
}

extension NetworkData {

    var api: String? {
        return nil
    }

    var method: HttpMethod {
        return .GET
    }

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
        guard let api = api else { return URL(string: host) }
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
        request.timeoutInterval = Timeout
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

extension String: NetworkData {
    var host: String {
        return  self
    }
}

struct ATResult {
    let data: Data?
    var cookies: [HTTPCookie]
    let error: ATError?

    static let nilValue: ATResult = ATResult(data: nil, error: nil)

    init(data: Data?, cookies: [HTTPCookie] = [], error: ATError?) {
        self.data = data
        self.cookies = cookies
        self.error = error
    }
}

class ATRequestManager {
    static let `default` = ATRequestManager()

    /// 异步发送网络请求
    /// - Parameters:
    ///   - data: 请求URL数据
    ///   - faildTimes: 失败重试次数
    ///   - complete: 完成回调
    func send(data: NetworkData, faildTimes:Int = 5, complete: ((ATResult) -> Void)?) {
        dataTask(request: data.request, faildTimes: faildTimes, complete: complete)
    }

    /// 网络请求
    /// - Parameters:
    ///   - request: 请求的数据
    ///   - isUseCookie: 是否使用cookie
    ///   - faildTimes: 失败重试次数
    ///   - complete: 回调
    private func dataTask(request: URLRequest?, faildTimes:Int, complete: ((ATResult) -> Void)?) {
        guard let request = request else {
            complete?(.nilValue)
            return
        }
        let configuration = URLSessionConfiguration.ephemeral
        // configuration.timeoutIntervalForRequest = 10
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { data, response, error in
            var result = ATResult(data: data, error: ATError(error: error))
            // request.httpShouldHandleCookies, 
            if let url = response?.url, let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String] {
                result.cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            }
            // 网络失败，且可以重试时
            if let error = error, faildTimes > 0 {
                print("\(faildTimes)-重试:\(error.localizedDescription)")
                sleep(1)
                self.dataTask(request: request, faildTimes: faildTimes-1, complete: complete)
                return
            }
            complete?(result)
        }
        task.resume()
    }
}
