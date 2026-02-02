# iOS APN Direct Setup - Native Method Channel

The Flutter app has been updated to request APN tokens directly from iOS without Firebase.

## What Changed

### ✅ Flutter App Changes

- Removed Firebase dependencies (firebase_core, firebase_messaging)
- Updated to use native iOS method channel
- App now requests APN token directly from iOS
- Simplified pubspec.yaml

### ✅ Native iOS Changes

- Updated `AppDelegate.swift` with:
  - Method channel implementation (`com.ruah.voip.test/apn`)
  - APN token request handler
  - Notification handling
  - Device token caching

### ✅ Server Compatible

- Server code (`index.js`) already expects APN tokens
- No changes needed to server
- Works perfectly with new direct APN approach

---

## How It Works Now

```
1. User launches app
   ↓
2. App calls native iOS: platform.invokeMethod('getAPNToken')
   ↓
3. iOS registers for remote notifications (APN)
   ↓
4. iOS returns device token
   ↓
5. App displays token in UI
   ↓
6. User copies token
   ↓
7. Server receives token
   ↓
8. Server sends via APN using your .p8 key
   ↓
9. iOS delivers notification to app
```

---

## Setup Steps

### Step 1: Clean Flutter Project

```bash
cd mobile_flutter
flutter clean
flutter pub get
```

### Step 2: Configure in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner project
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" with:
   - Remote notifications ✅
   - Background fetch ✅

### Step 3: Build and Run

```bash
flutter run -d <device_id>
```

### Step 4: Get Token

- App will display APN token automatically
- Copy the token
- Send to server

### Step 5: Send Notification

```bash
curl -X POST http://localhost:3000/send-to-token \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"YOUR_APN_TOKEN\"}"
```

---

## Key Differences from Firebase

| Feature | Firebase | Direct APN |
|---------|----------|-----------|
| **Token Source** | Firebase Cloud | iOS directly |
| **Dependencies** | Multiple (firebase_core, messaging) | None (native iOS) |
| **Setup Complexity** | Higher (need Firebase project) | Lower (just Xcode) |
| **Token Format** | FCM token | APN token (64 hex chars) |
| **Server Code** | Uses Firebase | Uses APN directly ✅ |
| **Control** | Firebase manages | You manage directly |

---

## Testing the New Setup

### 1. Run App

```bash
cd mobile_flutter
flutter run -d <device_id>
```

### 2. Wait for Token

- App shows "Requesting APN token..."
- Then shows 64-character hex token

### 3. Copy Token

- Use the "Copy Token" button in app
- Or manually select and copy

### 4. Test Server

```bash
npm run dev
```

### 5. Send Notification

```bash
curl -X POST http://localhost:3000/send-to-token \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"TOKEN_FROM_APP\"}"
```

### 6. Verify

- Check server logs: "Sent: 1, Failed: 0"
- Device receives notification
- App displays it

---

## File Changes Summary

### pubspec.yaml

- ❌ Removed: firebase_core, firebase_messaging, uuid
- ✅ Kept: Only cupertino_icons

### lib/main.dart

- ❌ Removed: All Firebase imports
- ✅ Added: MethodChannel import
- ✅ Added: Native platform channel call
- ✅ Updated: Token variable name and UI labels

### ios/Runner/AppDelegate.swift

- ✅ Added: FlutterMethodChannel setup
- ✅ Added: getAPNToken method
- ✅ Added: Device token registration
- ✅ Added: Notification handlers

### ios/Runner/Info.plist

- ✅ Already has: Push Notifications config

---

## Troubleshooting

### "MethodChannel MissingPluginException"

- Make sure AppDelegate.swift is properly updated
- Clean and rebuild: `flutter clean && flutter pub get`
- Check Xcode build log for errors

### "APNs token not available"

- Device must have internet connection
- Must have Push Notifications capability in Xcode
- Verify signing certificate is valid

### "Token shows 'Error: ...'"

- Check Flutter console for actual error
- Verify Xcode capabilities are added
- Try rebuilding with `flutter run --verbose`

### Notifications not received

- Verify token matches what's sent to server
- Check server logs for APN errors
- Verify APNs certificate (.p8 file) is valid
- Check iOS device has notifications enabled

---

## Code Structure

### Flutter → iOS Communication

```swift
// In AppDelegate.swift
let apnChannel = FlutterMethodChannel(
  name: "com.ruah.voip.test/apn",
  binaryMessenger: controller.binaryMessenger
)

// In main.dart
static const platform = MethodChannel('com.ruah.voip.test/apn');
final String apnToken = await platform.invokeMethod('getAPNToken');
```

### iOS → Server Communication

```bash
# Server receives APN token from app
# Sends via your existing APN integration
apnProvider.send(note, deviceToken)
```

---

## No Firebase Needed

✅ Everything works without Firebase  
✅ Direct iOS integration  
✅ Simpler setup  
✅ Full control  
✅ Lower dependencies  
✅ Faster app startup  

---

## Next Steps

1. Build and test the app
2. Get APN token from device
3. Send test notification from server
4. Verify notification delivery
5. Scale to multiple devices

---

## Support

If you encounter issues:

1. Check the error message in app (displays in UI)
2. Check `flutter run --verbose` output
3. Check Xcode console logs
4. Verify Xcode capabilities (Push Notifications + Background Modes)
5. Rebuild with `flutter clean && flutter pub get`

---

**Status:** ✅ Ready to test with native iOS APN tokens!
