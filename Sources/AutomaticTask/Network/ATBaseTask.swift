//
//  ATBaseNetwork.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

protocol AutomaticTask {
    var timeout:Int { get }
    func isFinish() -> Bool
}

class ATBaseTask: SafeClass, AutomaticTask {
    
    // 任务超时时间
    var timeout: Int = 15
    
    // 结束标识
    private var _finish = false
    
    func finish(_ finish:Bool=true) {
        _wait(); defer { _signal() }
        _finish = finish
    }
    
    func isFinish() -> Bool {
        _wait(); defer { _signal() }
        return _finish
    }
}
