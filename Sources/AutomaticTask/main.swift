//
//  main.swift
//  CommandLine
//
//  Created by 影孤清 on 2021/12/17.
//
import Foundation
import ArgumentParser

struct Repeat: ParsableCommand {
    @Option(help: "比思论坛参数")
    var picForum: String?
    
    @Flag(help: "抓取必应壁纸")
    var bingWallpaper = false
    
    @Flag(help: "禁用输出颜色")
    var disablePrintColor = false
    
    func run() {
        print("当前北京时间：\(Date.nowString())")
        let star = Date().timeIntervalSince1970
        var taskArray = SafeArray<AutomaticTask>()
        
        isPrintColor = !disablePrintColor
        
        // 必应壁纸
        if bingWallpaper {
            let bw = BingWallpaper()
            DispatchQueue.global().async {
                bw.run()
            }
            taskArray.append(bw)
        }
        
        // 比思签到
        if let data = picForum?.data(using: .utf8), let json = data.json as? [String: Any] {
            PFConfig.default = PFConfig(json: json)
            let pfNotice = ATNotice(json: json)
            taskArray.append(pfNotice)
            PFConfig.default.users.forEach {
                let pic = PicForum(user: $0, notice: pfNotice)
                pfNotice.targetCounts += 1
                taskArray.append(pic)
                DispatchQueue.global().async {
                    pic.run()
                }
                sleep(2)
            }
        }
        
        // 统计所有进程里超时时长，不超过2个小时(7200秒)
        let timeout = min(taskArray.map { $0.timeout }.reduce(0, +), 7200)
        while true {
            if taskArray.filter({ !$0.isFinish() }).isEmpty {
                break
            }
            // 超时直接结束
            if Int(Date().timeIntervalSince1970 - star) >= timeout {
                break
            }
            RunLoop.current.run(mode: .default, before: .init(timeIntervalSinceNow: 10))
        }
        let time = Date().timeIntervalSince1970 - star
        print("总耗时：\(time.timeFromat)")
    }
}
#if DEBUG
print("Debug")
#endif
Repeat.main()
