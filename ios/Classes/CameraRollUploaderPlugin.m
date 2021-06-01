#import "CameraRollUploaderPlugin.h"
#if __has_include(<camera_roll_uploader/camera_roll_uploader-Swift.h>)
#import <camera_roll_uploader/camera_roll_uploader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camera_roll_uploader-Swift.h"
#endif

@implementation CameraRollUploaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraRollUploaderPlugin registerWithRegistrar:registrar];
}
@end
