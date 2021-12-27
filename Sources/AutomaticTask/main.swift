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

    func run() {
        print("当前北京时间：\(Date.nowString())")
        let star = Int(Date().timeIntervalSince1970)
        var taskArray = SafeArray<AutomaticTask>()
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
            }
        }
        // 取出所有进程里超时时长最大值 * 2
        let timeout = (taskArray.map({ $0.timeout }).max() ?? 1200) * 2
        while true {
            if taskArray.filter({ !$0.isFinish() }).isEmpty {
                break
            }
            // 超时直接结束
            if Int(Date().timeIntervalSince1970) - star >= timeout {
                break
            }
            sleep(1)
        }
    }
}
Repeat.main()

