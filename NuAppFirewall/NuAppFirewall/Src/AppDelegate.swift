//
//  AppDelegate.swift
//  app
//
//  Created by Winicius Allan on 23/08/24.
//

import SwiftUI
import NetworkExtension

@main
class Main {
    
    static func main() async {
        print("sending request")
        
        let args = CommandLine.arguments
        let action = args[1]
        
        if (action == "activate") {
            await ExtensionManager.manager.toggleSystemExtension()
        }
        if (action == "deactivate") {
            ExtensionManager.manager.deactivateSysEx()
        }
        
        print("sysext is active and this is main thread")
//        await startSysExtension(args: args)
        
//        RunLoop.current.run()
        sleep(2000)
    }
    
}
