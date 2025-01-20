import AppKit
import SwiftUI
import Cocoa

extension NSImage.Name {
    static let menuAppIcon = NSImage.Name("MenuAppIcon")
}

@main
class MainApp: NSObject, NSApplicationDelegate {

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        print("menu item clicked")
    }
    
    var statusBarItem: NSStatusItem!
    
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
            }
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.image = NSImage(named: .menuAppIcon)
        } else {
            print("failed to create status bar button")
        }
    }
    

    static func main() {
        let app = NSApplication.shared
        let delegate = MainApp()
        app.delegate = delegate
        app.run()
    }
}

