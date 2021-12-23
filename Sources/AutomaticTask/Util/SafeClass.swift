//
//  SafeClass.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/21.
//

import Foundation

protocol Safe {
    var semaphore:DispatchSemaphore { get }
    func _wait()
    func _signal()
}

extension Safe {
    
    func _wait() {
        semaphore.wait()
    }
    
    func _signal() {
        semaphore.signal()
    }
}

class SafeClass: Safe {
    internal var semaphore = DispatchSemaphore(value: 1)
}
