//
//  RequestManager.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

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
    var url: URL { get }
    // 请求头参数
    var headerFields: [String: String?]? { get }
    // 请求参数
    var params: [String: String]? { get }
    // 请求bodyData
    var bodyData: Data? { get }
    // 请求方式
    var method: HttpMethod { get }
}

protocol AutomaticTask {
    var finish:Bool { get }
}

extension NetworkData {
    var headerFields: [String: String?]? {
        return nil
    }
    
    var params: [String: String]? {
        return nil
    }
    
    var bodyData: Data? {
        return nil
    }
    
    var url: URL {
        switch method {
            case .GET:
                var urlString = host.appending(pathComponent: api)
                if let params = params {
                    urlString.append("?")
                    urlString.append(params.map { "\($0.0)=\($0.1)" }.joined(separator: "&"))
                }
                return URL(string: urlString)!
            case .POST:
                return URL(string: host)!
        }
    }
}

class ATRequestManager {
    private init() {}
    
    /// 发送网络请求
    /// - Parameters:
    ///   - url: 请求URL
    ///   - method: 请求方式
    ///   - headerFields: 请求头参数
    ///   - bodyData: 请求body
    ///   - complete: 完成回调
    class func send(data: NetworkData, complete: ((Any?, ATError?) -> Void)?) {
        var request = URLRequest(url: data.url)
        // 设置超时时间
        // request.timeoutInterval = TimeInterval(15)
        request.httpMethod = data.method.rawValue
        
        // 请求头参数
        data.headerFields?.forEach {
            request.setValue($0.1, forHTTPHeaderField: $0.0)
        }
        request.httpBody = data.bodyData
        dataTask(request: request, complete: complete)
    }
    
    /// 网络请求
    /// - Parameters:
    ///   - request: 请求的数据
    ///   - complete: 回调
    class func dataTask(request: URLRequest, complete: ((Any?, ATError?) -> Void)?) {
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { data, _, error in
            complete?(data, ATError(error: error))
        }
        task.resume()
    }
}
