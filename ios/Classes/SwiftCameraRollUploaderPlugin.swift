import Flutter
import UIKit

public class SwiftCameraRollUploaderPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "camera_roll_uploader", binaryMessenger: registrar.messenger())
        let instance = SwiftCameraRollUploaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "fetch_photos_camera_roll" {
            let arguments = getCallArguments(arguments: call.arguments)
            let limit = (arguments["limit"] as? Int) ?? 21
            let cursor = (arguments["cursor"] as? Int) ?? 0
            CameraRollReader().fetchAllPhotos(fetchCount: limit, cursor: cursor, result: result)
        }
        if call.method == "select_photo_camera_roll" {
            let arguments = getCallArguments(arguments: call.arguments)
            let index = (arguments["index"] as? Int) ?? 0
            CameraRollReader().selectPhoto(index: index, result: result)
        }
    }
    
    private func getCallArguments(arguments: Any?) -> [String: Any] {
        if let arguments = arguments as? [String: Any] {
            return arguments
        }
        return [String: Any]()
    }
}
