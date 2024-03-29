//
//  ATConfig.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

/// 配置系统
class ATConfig: SafeClass {
    
    static let `default` = ATConfig()
    
    private var config:[String:Any]
    private let configPath:String
    
    override init() {
        let base = #file.deletingLastPathComponent.deletingLastPathComponent
        configPath = base.appending(pathComponent: "config.json")
        if configPath.fileExists, let data = try? Data(contentsOf: configPath.toFileURL) {
            let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String:Any]
            config = json ?? [String:Any]()
        } else {
            config = [String:Any]()
        }
    }
    
    func read(key:String) -> Any? {
        _wait(); defer{ _signal() }
        return config[key]
    }
    
    func save(key:String, value:Any) {
        _wait(); defer{ _signal() }
        config[key] = value
        writeFile()
    }
    
    func writeFile() {
        do {
            let data:Data
            if #available(macOS 10.13, *) {
                data = try JSONSerialization.data(withJSONObject: config, options: [.sortedKeys, .prettyPrinted])
            } else {
                data = try JSONSerialization.data(withJSONObject: config, options: .prettyPrinted)
            }
            try data.write(to: configPath.toFileURL)
        } catch {
            print("公用配置文件写入失败：\(error.localizedDescription)")
        }
    }
}


