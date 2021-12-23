//
//  BingWallpaper.swift
//  AutomaticTask
//
//  Created by 影孤清 on 2021/12/20.
//

import Foundation

class BingWallpaper: ATBaseTask {

    func run() {
        DispatchQueue.global().async {
            let net = BWNetwork()
            net.getWallPaper { flag in
                self.finish(flag ? .Success : .Faild)
            }
        }
    }
}
