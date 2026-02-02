import Flutter

import PushKit

import UIKit

import flutter_callkit_incoming

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
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

    // Register for VoIP push notifications
    let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [.voIP]

    // Request user notification permission
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      granted, error in
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - PKPushRegistryDelegate

  func pushRegistry(
    _ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType
  ) {
    let token = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
    print("VoIP Token: \(token)")

    // Send token to Flutter via flutter_callkit_incoming
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token)
  }

  func pushRegistry(
    _ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType, completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }

    // Extract call info from payload (customize based on your server payload)
    let id = UUID().uuidString
    let callerName = payload.dictionaryPayload["caller_name"] as? String ?? "Unknown Caller"
    let handle = payload.dictionaryPayload["caller_id"] as? String ?? ""

    let callData = flutter_callkit_incoming.Data(
      id: id, nameCaller: callerName, handle: handle, type: 0)
    callData.extra = payload.dictionaryPayload as NSDictionary

    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(
      callData, fromPushKit: true)
    completion()
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    print("VoIP token invalidated")
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
            let testToken = String(
              format:
                "%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255),
              UInt8.random(in: 0...255), UInt8.random(in: 0...255), UInt8.random(in: 0...255),
              UInt8.random(in: 0...255)
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
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Foundation.Data
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
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
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
