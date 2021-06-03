import Flutter
import UIKit

public class SwiftCameraRollUploaderPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "camera_roll_uploader", binaryMessenger: registrar.messenger())
        let instance = SwiftCameraRollUploaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        //        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        //        registrar.register(factory, withId: "<platform-view-type>")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print(call.method)
        let arguments = getCallArguments(arguments: call.arguments)
        print(arguments)
        let bgColor = (arguments["bgColor"] as? String) ?? "ffffff"
        let title = (arguments["title"] as? String) ?? ""
        let titleColor = (arguments["titleColor"] as? String) ?? "000000"
        let iosBackButtonImage = (arguments["iosBackButtonImage"] as? String) ?? "chevron.backward"
        let backButtonColor = (arguments["backButtonColor"] as? String) ?? "000000"
        let nextButtonColor = (arguments["nextButtonColor"] as? String) ?? "000000"
        let itemsPerRow = (arguments["itemsPerRow"] as? Int) ?? 3
        print("itemsPerRow \(itemsPerRow)")
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.modalPresentationStyle = .fullScreen
            let bundle = Bundle(identifier: "org.cocoapods.camera-roll-uploader")
            let controller = CameraRollViewController(nibName: "CameraRollViewController", bundle: bundle)
            controller.itemsPerRow = itemsPerRow
            controller.modalPresentationStyle = .fullScreen
            controller.view.backgroundColor = UIColor.fromHex(hex: bgColor)
            if #available(iOS 13.0, *) {
                controller.backButton.setBackgroundImage(UIImage(systemName: iosBackButtonImage), for: .normal)
            }
            controller.backButton.tintColor = UIColor.fromHex(hex: backButtonColor)
            controller.nextButton.tintColor = UIColor.fromHex(hex: nextButtonColor)
            controller.screenTitle.text = title
            controller.screenTitle.textColor = UIColor.fromHex(hex: titleColor)
            rootViewController.present(controller, animated: true, completion: nil)
        }
        
        //        let bundle = Bundle(identifier: "org.cocoapods.camera-roll-uploader")
        //        let controller = CameraRollViewController(nibName: "CameraRollViewController", bundle: bundle)
        //
        //        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        //            navigationController.pushViewController(controller, animated: true)
        //        }
        //
        //        let storyboard : UIStoryboard? = UIStoryboard.init(name: "Main", bundle: nil);
        //        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        //
        //        let objVC: UIViewController? = storyboard!.instantiateViewController(withIdentifier: "FlutterViewController")
        //        let aObjNavi = UINavigationController(rootViewController: objVC!)
        //        window.rootViewController = aObjNavi
        //        aObjNavi.navigationController?.navigationBar.isHidden = true
        //        aObjNavi.pushViewController(controller, animated: true)
    }
    
    func getCallArguments(arguments: Any?) -> [String: Any] {
        if let arguments = arguments as? [String: Any] {
            return arguments
        }
        return [String: Any]()
    }
}

public extension UIColor {
    
    class func fromHex(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
