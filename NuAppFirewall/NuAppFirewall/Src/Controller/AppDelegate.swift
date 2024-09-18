import SwiftUI
import NetworkExtension

@main
class Main {
    
    static func main() async {
        print("sending request")
        
        let manager = ExtensionManager()
        let args = CommandLine.arguments
        let action = args[1]
        
        if (action == "activate") {
            await manager.toggleSystemExtension()
        }
        if (action == "deactivate") {
            manager.deactivateSysEx()
        }
        
        print("sysext is active and this is main thread")

        sleep(2000)
    }
    
}
