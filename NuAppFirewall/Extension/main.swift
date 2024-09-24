import Foundation
import NetworkExtension
import OSLog

autoreleasepool {
    LogManager.shared.log("System extension mode was called")
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
