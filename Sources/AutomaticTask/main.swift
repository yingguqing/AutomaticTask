import Foundation

let bw = BWNetwork()
bw.getWallPaper()

var index = 0
while index < 3600 {
    if bw.finish {
        break
    }
    index += 1
    sleep(1)
}


print("ddddd")
