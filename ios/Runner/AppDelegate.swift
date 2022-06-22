import UIKit
import Flutter
import GoogleMaps
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyDCwjLEUa3QZYVv-XH3NojWIAMhPsGJ584")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

      // Black Screen when reduced
  
      /*// Hide your app’s key window when your app will resign active.
      — (void)applicationWillResignActive:(UIApplication *)application {
        self.window.hidden = YES;
      }
      // Show your app’s key window when your app becomes active again.
      — (void)applicationDidBecomeActive:(UIApplication *)application {
        self.window.hidden = NO;
      }*/
}

/*override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    let providerFactory = AppCheckDebugProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)
    return true
  }*/
