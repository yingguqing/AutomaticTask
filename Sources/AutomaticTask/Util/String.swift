//
//  String.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

extension String {
    /// 完整路径
    /// - Parameter fold: 目录
    /// - Returns: 路径
    func fullPath(fold: String? = nil) -> String {
        let base = fold ?? #file.deletingLastPathComponent.deletingLastPathComponent
        return base.appending(pathComponent: self)
    }
    
    var toFileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    func appending(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 删除后缀的文件名
    var fileNameWithoutExtension: String {
        return self.lastPathComponent.deletingPathExtension
    }
    
    /// 获得文件的扩展类型（不带'.'）
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    /// 从路径中获得完整的文件名（带后缀）
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    /// 删除最后一个/后面的内容 可以是整个文件名,可以是文件夹名
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    /// 获得文件名（不带后缀）
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    /// 文件是否存在
    var fileExists: Bool {
        guard !self.isEmpty else { return false }
        return FileManager.default.fileExists(atPath: self)
    }
    
    /// 目录是否存在，非目录时，返回false
    var directoryExists: Bool {
        guard !self.isEmpty else { return false }
        var isDirectory = ObjCBool(booleanLiteral: false)
        let isExists = FileManager.default.fileExists(atPath: self, isDirectory: &isDirectory)
        return isDirectory.boolValue && isExists
    }
    
    func pathRemove() {
        guard !self.isEmpty, self.fileExists else { return }
        do {
            try FileManager.default.removeItem(atPath: self)
        } catch let error as NSError {
            print("文件删除失败 \(error.localizedDescription)")
        }
    }
    
    // 生成目录所有文件
    @discardableResult func createFilePath(isDelOldPath: Bool = false) -> String {
        guard !self.isEmpty else { return self }
        do {
            if isDelOldPath, self.fileExists {
                self.pathRemove()
            } else if self.fileExists {
                return self
            }
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("创建目录失败 \(error.localizedDescription)")
        }
        return self
    }
    
    /// 日期格式转换
    func format(from: String, to: String) -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = from
        if let date = dformatter.date(from: self) {
            dformatter.dateFormat = to
            return dformatter.string(from: date)
        }
        return self
    }
    
    /// 字符串异或加密
    /// - Parameter key: 异或key
    /// - Returns: 异或结果
    func xorEncrypt(_ key: String) -> String {
        guard let data = self.data(using: .utf8), let keyData = key.data(using: .utf8) else { return self }
        return data.xorWith(keyData: keyData).base64EncodedString()
    }
    
    func urlAppendPathComponent(_ api: String) -> String {
        if !self.hasSuffix("/") && !api.hasPrefix("/") {
            return "\(self)/\(api)"
        } else if self.hasSuffix("/") || api.hasPrefix("/") {
            return self.appending(api)
        } else {
            return self.appending(String(api.dropFirst()))
        }
    }
    
    var urlEncode: String {
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: "!*'\"();:@&=+$,/?%#[]% ")
        return self.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? self
    }
    
    func urlAppend(params: [String: String]?) -> String {
        guard let params = params, !params.isEmpty else { return self }
        let paramString = params.map { "\($0.0.urlEncode)=\($0.1.urlEncode)" }.joined(separator: "&")
        if self.isEmpty {
            return paramString
        } else {
            return "\(self)&\(paramString)"
        }
    }
    
    enum StringRandomOptions {
        case Digits // 数字
        case LowerCase // 小写字母
        case UpperCase // 大写字母
        
        var list: [String] {
            switch self {
                case .Digits:
                    return "1234567890".map { String($0) }
                case .LowerCase:
                    return "abcdefghigklmnopqrstuvwxyz".map { String($0) }
                case .UpperCase:
                    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
            }
        }
    }
    
    /// 随机字符串
    /// - Parameters:
    ///   - count: 长度
    ///   - options: 类型
    /// - Returns: 结果
    static func random(_ count: Int, options: [StringRandomOptions] = [.Digits, .LowerCase, .UpperCase]) -> String {
        guard count > 0, !options.isEmpty else { return "" }
        let list = options.map { $0.list }.flatMap { $0 }.shuffled()
        var result = [String]()
        for _ in 0..<count {
            result.append(list.randomElement()!)
        }
        return result.joined()
    }
}
