import Foundation
import SystemExtensions
import NetworkExtension

class ExtensionManager : NSObject, OSSystemExtensionRequestDelegate {
    
    override init() {}
    
    var reply: Bool?
    let identifier = "com.nufuturo.nuappfirewall.extension"
    
    func toggleSystemExtension() async {
        do {
            let toggled = await activateSysExtension()
            
            if !toggled {
                print("error when activating sysex")
                return
            }
            
            sleep(5)
            let filterActivate = await startNetworkExtension()
            
            if !filterActivate {
                print("error when activating filter")
                return
            }
            
            print("system extension is running")
            
        }
    }
    
    func startNetworkExtension() async -> Bool {
        print("starting network extension")
        
        return await withCheckedContinuation { continuation in
            let config = NEFilterProviderConfiguration()
            
            print("loading preferences")
            NEFilterManager.shared().loadFromPreferences { error in
                if let error = error {
                    print("error when loading preferences", error)
                }
            
                config.filterPackets = false
                config.filterSockets = true
                config.filterDataProviderBundleIdentifier = self.identifier;
                NEFilterManager.shared().providerConfiguration = config
                NEFilterManager.shared().isEnabled = true
                
                print("saving to preferences")
                NEFilterManager.shared().saveToPreferences { error in
                    if let error = error {
                        print("error when saving to preferences", error.localizedDescription)
                        return
                    }
                    continuation.resume(returning: true)
                }
            }
        }
    }

    
    func activateSysExtension() async -> Bool {
        print("calling activation request")
        
        return await withCheckedContinuation { continuation in
            let activationRequest = OSSystemExtensionRequest.activationRequest(forExtensionWithIdentifier: identifier, queue: .main)
            activationRequest.delegate = self
            OSSystemExtensionManager.shared.submitRequest(activationRequest)
            
            self.systemExtensionActivationCallback = { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    private var systemExtensionActivationCallback: ((Bool) -> Void)?
    
    
    func deactivateSysEx() {
        print("calling activation request")
        let deactivationRequest = OSSystemExtensionRequest.deactivationRequest(forExtensionWithIdentifier: identifier, queue: .main)
        deactivationRequest.delegate = self
        OSSystemExtensionManager.shared.submitRequest(deactivationRequest)
    }
    
    func request(_ request: OSSystemExtensionRequest, actionForReplacingExtension existing: OSSystemExtensionProperties, withExtension ext: OSSystemExtensionProperties) -> OSSystemExtensionRequest.ReplacementAction {
        
        print("sysex action for replace existing extension %@ %@", existing, ext)
        
        return .replace
    }
    
    func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        print("sysex needs user approval")
        self.reply = false
    }
    
    func request(_ request: OSSystemExtensionRequest, didFinishWithResult result: OSSystemExtensionRequest.Result) {
        print("sysex did finish with result %@", result.rawValue)
        
        let success = (result == .completed)
        systemExtensionActivationCallback?(success)
    }
    
    func request(_ request: OSSystemExtensionRequest, didFailWithError error: any Error) {
        print("did fail with error %@", error.localizedDescription)
        systemExtensionActivationCallback?(false)
    }
    
}

