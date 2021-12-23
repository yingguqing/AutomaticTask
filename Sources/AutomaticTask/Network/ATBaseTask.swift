//
//  ATBaseNetwork.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

class ATBaseTask: SafeClass, AutomaticTask {
    
    enum TaskType {
        case Ready // 准备
        case Success // 成功
        case Faild // 失败
        case Running // 运行中
        
        var isFinish:Bool {
            return self != .Running && self != .Ready
        }
    }
    
    // 功能是否结束标识
    private var _taskType: TaskType = .Ready
    
    func finish(_ type:TaskType) {
        _wait(); defer { _signal() }
        _taskType = type
    }
    
    func finish() -> Bool {
        _wait(); defer { _signal() }
        return _taskType.isFinish
    }
}
