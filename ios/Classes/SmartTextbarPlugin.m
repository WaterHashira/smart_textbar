#import "SmartTextbarPlugin.h"
#if __has_include(<smart_textbar/smart_textbar-Swift.h>)
#import <smart_textbar/smart_textbar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "smart_textbar-Swift.h"
#endif

@implementation SmartTextbarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftSmartTextbarPlugin registerWithRegistrar:registrar];
}
@end
