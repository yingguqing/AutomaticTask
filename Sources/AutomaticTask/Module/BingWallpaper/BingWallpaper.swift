//
//  BingWallpaper.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

class BingWallpaper: ATBaseTask {
    struct BWImage {
        var url: String
        let endDate: String
        let copyRight: String
        let showDate: String
        
        init(json: [String: Any]) {
            if var u = json["url"] as? String {
                if let low = u.range(of: "&") {
                    u = String(u[u.startIndex..<low.lowerBound])
                }
                url = u
            } else {
                url = ""
            }
            endDate = json["enddate"] as? String ?? ""
            copyRight = json["copyright"] as? String ?? ""
            showDate = endDate.format(from: "YYYYMMdd", to: "YYYY-MM-dd")
        }
        
        // 其他日期的图片展示
        var toString: String {
            let smallUrl = url + "&pid=hp&w=384&h=216&rs=1&c=4"
            return "![](\(smallUrl))\(showDate) [download 4k](\(url))"
        }
        
        // 今天的图片展示
        var toLarge: String {
            let smallUrl = url + "&w=1000"
            return "![](\(smallUrl))Today: [\(copyRight)](\(url))"
        }
        
        var toJson: [String: String] {
            return [
                "enddate": endDate,
                "url": url,
                "copyright": copyRight
            ]
        }
    }
    
    func run() {
        BWNetwork.getWallPaper { json in
            if let todayJson = json?["images"] as? [[String: Any]], let first = todayJson.first {
                var today = BingWallpaper.BWImage(json: first)
                today.url = BWNetwork.API.HPImageArchive.host + today.url
                self.save(image: today)
            } else {
                self.finish()
            }
        }
    }
    
    /// 保存壁纸数据
    /// - Parameter image: 今天的壁纸
    func save(image: BWImage) {
        let jsonURL = "bing-wallpaper.json".fullPath.toFileURL
        do {
            let data = try Data(contentsOf: jsonURL)
            var imageJsonArrays = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [[String: Any]]
            let historyImages = imageJsonArrays.map { BWImage(json: $0) }
            if let first = historyImages.first, first.url == image.url {
                print("数据相同，不添加")
            } else {
                try writeReadMe(images: historyImages, today: image)
                imageJsonArrays.insert(image.toJson, at: 0)
                let data = try JSONSerialization.data(withJSONObject: imageJsonArrays, options: .prettyPrinted)
                try data.write(to: jsonURL)
            }
        } catch {
            print("必应壁纸报错：\(error.localizedDescription)")
        }
        finish()
    }
    
    /// 将壁纸内容写入到ReadMe.md中
    /// - Parameters:
    ///   - images: 历史壁纸
    ///   - today: 今天的壁纸
    func writeReadMe(images: [BWImage], today: BWImage) throws {
        var lines = [String]()
        lines.append("## Bing Wallpaper")
        lines.append(today.toLarge)
        lines.append("|      |      |      |")
        lines.append("| :----: | :----: | :----: |")
        var group = [BWImage]()
        for image in images {
            group.append(image)
            if group.count == 3 {
                let string = "|\(group.map { $0.toString }.joined(separator: "|"))|"
                lines.append(string)
                group = [BWImage]()
            }
        }
        if !group.isEmpty {
            let string = "|\(group.map { $0.toString }.joined(separator: "|"))|"
            lines.append(string)
        }
        let url = "README.md".fullPath.toFileURL
        try lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
    }
}

private extension String {
    var fullPath: String {
        let base = #file.deletingLastPathComponent
        return base.appending(pathComponent: self)
    }
}
