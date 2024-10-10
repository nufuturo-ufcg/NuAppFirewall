import AppKit

@main
class MainApp: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("sending request")
        
        let isTesting = NSClassFromString("XCTestCase") != nil
        if isTesting {
            print("running in test mode")
            return
        }

        let manager = ExtensionManager()
        Task {
            await manager.toggleSystemExtension()
            print("sysext is active and this is main thread")
            NSApp.terminate(nil)
        }
    }

    static func main() {
        let app = NSApplication.shared
        let delegate = MainApp()
        app.delegate = delegate
        app.run()
    }
}
