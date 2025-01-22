import AppKit
import SwiftUI

@main
class MainApp: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    
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
        
        self.setupStatusBarItem()
        self.setupPopover()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.showPopover(self.statusBarItem.button!)
    }
    
    private func setupStatusBarItem() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.action = #selector(showPopover(_:))
            button.target = self
            button.image = NSImage(named: .menuAppIcon)
            button.toolTip = "NuAppFirewall"
        } else {
            print("failed to create status bar button")
        }
    }
    
    private func setupPopover() {
        let contentView = PopoverWindow()
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 350)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
    }
    
    @objc func showPopover(_ sender: NSStatusBarButton) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
    

    static func main() {
        let app = NSApplication.shared
        let delegate = MainApp()
        app.delegate = delegate
        app.run()
    }
}

extension NSImage.Name {
    static let menuAppIcon = NSImage.Name("MenuAppIcon")
}

