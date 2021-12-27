//
//  ATConfig.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation


class ATConfig: SafeClass {
    
    static let `default` = ATConfig()
    
    private var config:[String:Any]
    
    let configPath:String
    
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
            let data = try JSONSerialization.data(withJSONObject: config, options: [.sortedKeys, .prettyPrinted])
            try data.write(to: configPath.toFileURL)
        } catch {
            print("公用配置文件写入失败：\(error.localizedDescription)")
        }
    }
}


