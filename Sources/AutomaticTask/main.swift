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
        var taskArray = SafeArray<AutomaticTask>()
        if bingWallpaper {
            let bw = BingWallpaper()
            DispatchQueue.global().async {
                bw.run()
            }
            taskArray.append(bw)
        }
        if let data = picForum?.data(using: .utf8) {
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                    return
                }
                PFConfig.default = PFConfig(json: json)
                let pfNotice = ATNotice(json: json)
                if let user = PFConfig.default.users.last {
                    let pic = PicForum(user: user, notice: pfNotice)
                    DispatchQueue.global().async {
                        pic.run()
                    }
                    taskArray.append(pic)
                }
            } catch {
                print("比思参数解析失败：\(error.localizedDescription)")
            }
        }
        var index = 0
        while index < 3600 {
            if taskArray.filter({ !$0.finish() }).isEmpty {
                break
            }
            index += 1
            sleep(1)
        }
    }
}
Repeat.main()
