import Foundation
import NetworkExtension
import OSLog

autoreleasepool {
    LogManager.logManager.log("System extension mode was called")
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
