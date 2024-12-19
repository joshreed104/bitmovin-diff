import BitmovinPlayer

@objc(BitmovinCastManagerModule)
public class BitmovinCastManagerModule: NSObject, RCTBridgeModule {
    // swiftlint:disable:next implicitly_unwrapped_optional
    @objc public var bridge: RCTBridge!

    // swiftlint:disable:next implicitly_unwrapped_optional
    public static func moduleName() -> String! {
        "BitmovinCastManagerModule"
    }

    public static func requiresMainQueueSetup() -> Bool {
        true
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    public var methodQueue: DispatchQueue! {
        bridge.uiManager.methodQueue
    }

    /**
     Initializes the BitmovinCastManager with the given options or with no options when none given.
     */
    @objc(initializeCastManager:resolver:rejecter:)
    func initializeCastManager(
        _ config: Any?,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
#if os(iOS)
        bridge.uiManager.addUIBlock { _, _ in
            if let config {
                guard let options = RCTConvert.castManagerOptions(config) else {
                    reject("BitmovinCastManagerModule", "Could not deserialize BitmovinCastManagerOptions", nil)
                    return
                }
                BitmovinCastManager.initializeCasting(options: options)
                resolve(nil)
            } else {
                BitmovinCastManager.initializeCasting()
                resolve(nil)
            }
        }
#endif
    }

    /**
     Returns true if casting is already initialized.
     - Parameter resolver: JS promise resolver.
     - Parameter rejecter: JS promise rejecter.
     */
    @objc(isInitialized:rejecter:)
    func isInitialized(
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        bridge.uiManager.addUIBlock { _, _ in
#if os(iOS)
            resolve(BitmovinCastManager.isInitialized())
#else
            resolve(false)
#endif
        }
    }

    /**
     Sends the given message to the cast receiver on the provided namespace.
     If no namespace is provided, the one returned by defaultChannel.protocolNamespace is used.
     */
    @objc(sendMessage:messageNamespace:)
    func sendMessage(
        _ message: String,
        messageNamespace: String?
    ) {
#if os(iOS)
        bridge.uiManager.addUIBlock { _, _ in
            BitmovinCastManager.sharedInstance().sendMessage(message, withNamespace: messageNamespace)
        }
#endif
    }
}
