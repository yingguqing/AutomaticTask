//
//  Util.swift
//  Demo
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

extension Date {
    
    static func today(_ format:String="YYYY/MM/dd") -> String {
        return Date().format(format)
    }
    
    static func nowString(_ format:String="YYYY-MM-dd HH:mm:ss") -> String {
        return Date().format(format)
    }
    
    func format(_ format:String="YYYY-MM-dd HH:mm:ss") -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = format
        return dformatter.string(from: self)
    }
}
