//
//  ATBaseNetwork.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

// 全局超时时间
let Timeout:Double = 60

protocol AutomaticTask {
    var timeout:Int { get }
    func isFinish() -> Bool
}

class ATBaseTask: SafeClass, AutomaticTask {
    
    // 结束标识
    private var _finish = false
    var timeout:Int = Int(Timeout)

    func finish(_ finish:Bool=true) {
        _wait(); defer { _signal() }
        _finish = finish
    }
    
    func isFinish() -> Bool {
        _wait(); defer { _signal() }
        return _finish
    }
}
