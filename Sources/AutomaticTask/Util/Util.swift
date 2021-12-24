//
//  Util.swift
//  Demo
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

extension Date {
    static func today(_ format: String = "YYYY/MM/dd") -> String {
        return Date().format(format)
    }
    
    static func nowString(_ format: String = "YYYY-MM-dd HH:mm:ss") -> String {
        return Date().format(format)
    }
    
    func format(_ format: String = "YYYY-MM-dd HH:mm:ss") -> String {
        let dformatter = DateFormatter()
        dformatter.locale = Locale(identifier: "zh_CN")
        dformatter.dateFormat = format
        return dformatter.string(from: self)
    }
}

extension Data {
    /// 异或数据
    ///
    /// - Parameter keyData: 异或所用的key
    /// - Returns: 异或后的数据
    func xorWith(keyData: Data) -> Data {
        var bytes: [UInt8] = []
        self.withUnsafeBytes { bytes.append(contentsOf: $0) }
        var keyBytes: [UInt8] = []
        keyData.withUnsafeBytes { keyBytes.append(contentsOf: $0) }
        var keyIndex = 0
        let length = bytes.count
        let keyLength = keyBytes.count
        for x in 0..<length {
            bytes[x] = bytes[x] ^ keyBytes[keyIndex % keyLength]
            keyIndex += 1
        }
        
        return Data(bytes: bytes, count: length)
    }
    
    var text: String? {
        return String(data: self, encoding: .utf8)
    }
    
    var json: Any? {
        return try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed)
    }
}

extension Dictionary where Key == String {
    
    func value<T>(key:String, defaultValue:T) -> T {
        guard let value = self[key] else { return defaultValue }
        if type(of: defaultValue) == Int.self {
            var result:Int? = nil
            if let val = value as? Int {
                result = val
            } else if let val = value as? String {
                result = Int(val)
            } else if let val = value as? Double {
                result = Int(val)
            } else if let val = value as? Bool {
                result = (val ? 1 : 0)
            }
            return result as? T ?? defaultValue
        } else if type(of: defaultValue) == String.self {
            var result:String? = nil
            if let val = value as? Int {
                result = String(val)
            } else if let val = value as? String {
                result = val
            } else if let val = value as? Double {
                result = String(val)
            } else if let val = value as? Bool {
                result = (val ? "true" : "false")
            }
            return result as? T ?? defaultValue
        } else if type(of: defaultValue) == Bool.self {
            var result:Bool? = nil
            if let val = value as? Int {
                result = val != 0
            } else if let val = value as? String {
                let low = val.lowercased()
                if low == "true" || low == "1" {
                    result = true
                } else if low == "false" || low == "0" {
                    result = false
                } else {
                    result = !val.isEmpty
                }
            } else if let val = value as? Double {
                result = val != 0
            } else if let val = value as? Bool {
                result = val
            }
            return result as? T ?? defaultValue
        } else if type(of: defaultValue) == Double.self {
            var result:Double? = nil
            if let val = value as? Int {
                result = Double(val)
            } else if let val = value as? String {
                result = Double(val)
            } else if let val = value as? Double {
                result = val
            } else if let val = value as? Bool {
                result = Double(val ? 1 : 0)
            }
            return result as? T ?? defaultValue
        }
        return defaultValue
    }
}

extension Double {
    
    var timeFromat:String {
        let min = Int(self / 60)
        let second = self - Double(min*60)
        if min > 0 {
            return String(format: "%d分%.2f秒", min, second)
        } else {
            return String(format: "%.2f秒", min, second)
        }
    }
}
