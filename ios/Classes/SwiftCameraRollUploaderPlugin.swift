import Flutter
import UIKit

public class SwiftCameraRollUploaderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "camera_roll_uploader", binaryMessenger: registrar.messenger())
        let instance = SwiftCameraRollUploaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        print(call.arguments ?? "No arguments")
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.modalPresentationStyle = .fullScreen
            let bundle = Bundle(identifier: "org.cocoapods.camera-roll-uploader")
            let controller = CameraRollViewController(nibName: "CameraRollViewController", bundle: bundle)
            rootViewController.present(controller, animated: true, completion: nil)
        }
    }
}
