//
//  LogInfo.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

// 日志类型
enum ATPrintType: Int {
    // 正常打印，没有颜色
    case Normal = 0
    // 34-37之间随机颜色
    case Info = 1
    // 蓝色
    case Blue = 34
    // 洋红
    case Magenta = 35
    // 青色
    case Cyan = 36
    // 白色
    case White = 37
    // 警告
    case Warn = 33
    // 成功
    case Success = 32
    // 失败
    case Faild = 31
    
    // 根据类型，生成相应颜色的文字
    func colorText(_ text: String) -> String {
        #if DEBUG
        return text
        #else
        let index = self == .Info ? Int.random(in: 34...37) : rawValue
        return "\033[7;30;\(index)m\(text)\033[0m"
        #endif
    }
}

struct ATLogInfo: Safe {
    internal let semaphore = DispatchSemaphore(value: 1)
    /// 日志内容
    let log: String
    /// 日志类型
    let type: ATPrintType
    /// 日志标题（非必须）
    let title: String
    /// 日志保存文件名（非必须）
    let logName: String
    
    init(log: String, type: ATPrintType, title: String = "", logName: String = "") {
        self.log = log
        self.type = type
        self.title = title
        self.logName = logName
    }
    
    /// 保存日志到文件中
    func saveLogToText() {
        _wait(); defer { _signal() }
        guard !logName.isEmpty else { return }
        let time = Date.nowString()
        let base = #file.deletingLastPathComponent.deletingLastPathComponent
        let path = base.appending(pathComponent: "Logs/\(logName)")
        // 创建目录
        path.deletingLastPathComponent.createFilePath()
        do {
            var logText = ""
            if path.fileExists {
                logText = try String(contentsOfFile: path)
            }
            logText = "\(time):\(log)" + logText
            try logText.write(to: path.toFileURL, atomically: true, encoding: .utf8)
        } catch {
            Swift.print("保存日志到文件失败：\(error.localizedDescription)")
        }
    }
    
    /// 打印当前日志
    func print() {
        var value = title
        if !value.isEmpty {
            value.append("：")
        }
        value.append(type.colorText(log))
        Swift.print(value)
    }
}

class ATPrintLog {
    // 标题
    let title: String
    // 是否是debug模式，debug模式会打印每条日志
    private var isDebug = false
    // 日志名称，设置了名称，就自动进入Debug模式
    var logName = "" {
        didSet {
            isDebug = !logName.isEmpty
        }
    }
    
    // 记录所有日志的数组
    private var logs = SafeArray<ATLogInfo>()
    
    init(title: String) {
        self.title = title
    }
    
    /// 记录日志列表，并打印日志
    /// - Parameters:
    ///   - info: 日志信息
    ///   - isDebug: 是否是debug信息，debug信息只有在系统为debug模式下，才显示
    private func print(info: ATLogInfo, isDebug: Bool) {
        if !isDebug || self.isDebug {
            logs.append(info)
        }
        guard !self.isDebug else { return }
        info.saveLogToText()
        info.print()
    }
    
    /// debug模式下日志输出
    /// - Parameters:
    ///   - text: 单条日志
    ///   - texts: 批量日志
    ///   - type: 日志类型
    func debugPrint(text: String? = nil, texts: [String] = [], type: ATPrintType) {
        if let text = text {
            let info = ATLogInfo(log: text, type: type, title: title, logName: logName)
            print(info: info, isDebug: true)
        } else if !texts.isEmpty {
            texts.forEach {
                debugPrint(text: $0, type: type)
            }
        }
    }
    
    /// 打印日志
    /// - Parameters:
    ///   - text: 单条日志
    ///   - texts: 批量日志
    ///   - type: 日志类型
    func print(text: String? = nil, texts: [String] = [], type: ATPrintType) {
        if let text = text {
            let info = ATLogInfo(log: text, type: type, title: title, logName: logName)
            print(info: info, isDebug: false)
        } else if !texts.isEmpty {
            texts.forEach {
                print(text: $0, type: type)
            }
        }
    }
    
    /// 清空所有日志
    func clean() {
        logs.removeAll()
    }
    
    /// 打印记录下来的日志
    func printLog(options:[ATPrintType]=[.Success, .Warn, .Faild, .Blue, .Normal, .Cyan, .Info, .Magenta, .White]) {
        guard !logs.isEmpty else { return }
        if isDebug {
            Swift.print("\n\n\n\n\n")
        }
        let all = logs.filter({ options.contains($0.type) }).map { $0.type.colorText($0.log) }.joined(separator: "\n")
        Swift.print("\(all)\n")
    }
}
