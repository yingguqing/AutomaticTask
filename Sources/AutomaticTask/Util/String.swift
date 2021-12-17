//
//  String.swift
//
//
//  Created by 影孤清 on 2021/12/17.
//

import Foundation

extension String {
    /// 完整路径
    /// - Parameter fold: 目录
    /// - Returns: 路径
    func fullPath(fold: String? = nil) -> String {
        let base = fold ?? #file.deletingLastPathComponent.deletingLastPathComponent
        return base.appending(pathComponent: self)
    }
    
    var toFileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    func appending(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 删除后缀的文件名
    var fileNameWithoutExtension: String {
        return self.lastPathComponent.deletingPathExtension
    }
    
    /// 获得文件的扩展类型（不带'.'）
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    /// 从路径中获得完整的文件名（带后缀）
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    /// 删除最后一个/后面的内容 可以是整个文件名,可以是文件夹名
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    /// 获得文件名（不带后缀）
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    /// 文件是否存在
    var fileExists: Bool {
        guard !self.isEmpty else { return false }
        return FileManager.default.fileExists(atPath: self)
    }
    
    /// 目录是否存在，非目录时，返回false
    var directoryExists: Bool {
        guard !self.isEmpty else { return false }
        var isDirectory = ObjCBool(booleanLiteral: false)
        let isExists = FileManager.default.fileExists(atPath: self, isDirectory: &isDirectory)
        return isDirectory.boolValue && isExists
    }
    
    func pathRemove() {
        guard !self.isEmpty, self.fileExists else { return }
        do {
            try FileManager.default.removeItem(atPath: self)
        } catch let error as NSError {
            print("文件删除失败 \(error.localizedDescription)")
        }
    }
    
    // 生成目录所有文件
    @discardableResult func createFilePath(isDelOldPath: Bool = false) -> String {
        guard !self.isEmpty else { return self }
        do {
            if isDelOldPath, self.fileExists {
                self.pathRemove()
            } else if self.fileExists {
                return self
            }
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("创建目录失败 \(error.localizedDescription)")
        }
        return self
    }
    
    /// 日期格式转换
    func format(from:String, to:String) -> String {
        let dformatter = DateFormatter()
        dformatter.dateFormat = from
        if let date = dformatter.date(from: self) {
            dformatter.dateFormat = to
            return dformatter.string(from: date)
        }
        return self
    }
}
