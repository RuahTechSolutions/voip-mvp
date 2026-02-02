import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let apnChannel = FlutterMethodChannel(
      name: "com.ruah.voip.test/apn",
      binaryMessenger: controller.binaryMessenger
    )
    
    apnChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getAPNToken":
        self.getAPNToken(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Request user notification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func getAPNToken(result: @escaping FlutterResult) {
    // Get the device token for APN
    DispatchQueue.main.async {
      let token = UIApplication.shared.isRegisteredForRemoteNotifications
      if token {
        // Token will be available in didRegisterForRemoteNotificationsWithDeviceToken
        // Store a reference to the result handler
        UserDefaults.standard.setValue("pending", forKey: "apnTokenRequest")
        // Request remote notification registration
        UIApplication.shared.registerForRemoteNotifications()
        
        // For testing, return a placeholder
        // In production, this would be called from didRegisterForRemoteNotificationsWithDeviceToken
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
          if let token = UserDefaults.standard.string(forKey: "cachedAPNToken") {
            result(token)
          } else {
            // Generate a test token format for demonstration
            let testToken = String(format: "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255)
            )
            result(testToken)
          }
        }
      } else {
        result(FlutterError(code: "NOT_AVAILABLE", message: "APNs not available", details: nil))
      }
    }
  }
  
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("APNs Device Token: \(token)")
    UserDefaults.standard.setValue(token, forKey: "cachedAPNToken")
  }
  
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
  }
  
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    print("Notification received in foreground: \(notification.request.content.userInfo)")
    completionHandler([.banner, .sound, .badge])
  }
  
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("Notification tapped: \(response.notification.request.content.userInfo)")
    completionHandler()
  }
}
