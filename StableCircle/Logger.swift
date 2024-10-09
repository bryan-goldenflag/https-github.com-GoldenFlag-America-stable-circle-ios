import Foundation
import OSLog

func log(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    let fileName = (file as NSString).lastPathComponent
    let output = "[\(fileName):\(line)] \(function): \(message)"
    os_log(.debug, "%{public}@", output)
}
