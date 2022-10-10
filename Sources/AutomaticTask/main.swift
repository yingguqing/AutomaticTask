//
//  main.swift
//  CommandLine
//
//  Created by 影孤清 on 2021/12/17.
//
import Foundation
import ArgumentParser

struct Repeat: ParsableCommand {
    @Option(help: "手机通知")
    var notice: String?

    @Option(help: "比思论坛参数")
    var picForum: String?
    
    @Flag(help: "抓取必应壁纸")
    var bingWallpaper = false
    
    @Option(help: "debug模式")
    var debug:String?
    
    func run() {
        print("当前北京时间：\(Date.nowString())")
        let isDebug = debug == "1"
        let star = Date().timeIntervalSince1970
        var taskArray = SafeArray<AutomaticTask>()
        
        // 必应壁纸
        if bingWallpaper {
            let bw = BingWallpaper()
            DispatchQueue.global().async {
                bw.run()
            }
            taskArray.append(bw)
        }

        // 手机通知
        ATNotice.default.noticeKey = notice
        
        // 比思签到
        if let data = picForum?.data(using: .utf8), let json = data.json as? [String: Any] {
            PFConfig.default.update(json: json)
            let pics = PFConfig.default.run(isDebug: isDebug)
            taskArray += pics
            ATNotice.default.targetCounts += pics.count
        }
        
        // 有通知需求时，把通知加到任务列表中
        if ATNotice.default.isValid {
            taskArray.append(ATNotice.default)
        }
        
        // 统计所有进程里超时时长，不超过2个小时(7200秒)
        let timeout = min(taskArray.map { $0.timeout }.reduce(0, +), 7200)
        while true {
            if taskArray.filter({ !$0.isFinish() }).isEmpty {
                break
            }
            // 超时直接结束
            if Int(Date().timeIntervalSince1970 - star) >= timeout {
                print("任务超过最大时长。")
                break
            }
            //sleep(10)
            Thread.sleep(forTimeInterval: 10)
        }
        let time = Date().timeIntervalSince1970 - star
        print("总耗时：\(time.timeFromat)")
    }
}

Repeat.main()

