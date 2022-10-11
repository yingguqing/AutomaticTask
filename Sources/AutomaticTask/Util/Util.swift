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
        // 转成中国时区，上海时间
        dformatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
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
