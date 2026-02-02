# iOS VoIP Setup Checklist

Use this checklist to ensure you've completed all setup steps.

## 📋 Phase 1: Firebase Project Setup

### Firebase Console

- [ ] Created Firebase project
- [ ] Added iOS app
  - [ ] Bundle ID: `com.ruah.voip.test`
  - [ ] Team ID: `3756UBXGBX`
- [ ] Downloaded `GoogleService-Info.plist`
- [ ] Saved plist file to known location

### APNs Configuration

- [ ] Generated APNs certificate (or have existing)
- [ ] Uploaded to Firebase Console
- [ ] Cloud Messaging section configured
- [ ] Verified Bundle ID in Firebase settings
- [ ] Verified Team ID in Firebase settings

## 📱 Phase 2: iOS Project Configuration

### Xcode Setup

- [ ] Opened `ios/Runner.xcworkspace` (NOT .xcodeproj!)
- [ ] Added `GoogleService-Info.plist` to Runner target
  - [ ] File is in Runner folder
  - [ ] Runner target is checked
- [ ] Verified bundle identifier: `com.ruah.voip.test`
- [ ] Set Team ID
- [ ] Selected valid signing certificate

### Capabilities

- [ ] Added "Push Notifications" capability
- [ ] Added "Background Modes" capability
  - [ ] "Remote notifications" selected
  - [ ] "Background fetch" selected

### Pod Installation

- [ ] Ran `pod install` in ios/ folder
- [ ] No errors in pod output
- [ ] Podfile.lock generated

## 🎯 Phase 3: Flutter App Configuration

### Dependencies

- [ ] Ran `flutter pub get`
- [ ] All packages installed successfully
- [ ] No version conflicts

### Firebase Options

- [ ] Updated `lib/firebase_options.dart`
  - [ ] API Key (from GoogleService-Info.plist)
  - [ ] App ID (from GoogleService-Info.plist)
  - [ ] Messaging Sender ID
  - [ ] Project ID
  - [ ] Bundle ID: `com.ruah.voip.test`
  - [ ] All values non-empty (no placeholders)

### App Code

- [ ] `lib/main.dart` compiled without errors
- [ ] Firebase imports resolve
- [ ] No red squiggly lines in editor

## 💻 Phase 4: Server Setup

### Dependencies

- [ ] Ran `npm install`
- [ ] All packages installed successfully
- [ ] node_modules folder created
- [ ] package-lock.json generated

### Server Configuration

- [ ] `AuthKey_F22HR33BNR.p8` is in project root
- [ ] `index.js` has correct credentials:
  - [ ] Key: "AuthKey_F22HR33BNR.p8"
  - [ ] Key ID: "F22HR33BNR"
  - [ ] Team ID: "3756UBXGBX"
  - [ ] Topic: "com.ruah.voip.test"

### Server Testing

- [ ] Started with `npm run dev`
- [ ] Listens on port 3000
- [ ] No errors in startup
- [ ] Health check responds: `curl http://localhost:3000/health`

## 🚀 Phase 5: Device Testing

### Preparation

- [ ] Physical iOS device available
- [ ] Device connected to Mac with cable
- [ ] Device unlocked
- [ ] Device has internet connection
- [ ] Trust certificate on device (if prompted)

### Flutter Installation

- [ ] Ran `flutter devices` - device listed
- [ ] Device shows "ios" type
- [ ] Device is not locked when running flutter run

### App Installation

- [ ] Ran `flutter run -d <device_id>`
- [ ] App compiled successfully
- [ ] No build errors
- [ ] App launched on device

### Token Generation

- [ ] App shows "VoIP Token Information"
- [ ] FCM Token displays (not "Not initialized")
- [ ] Token is 64 hex characters (256 bits)
- [ ] Token can be copied to clipboard
- [ ] Got screenshot/copy of token for testing

## 📡 Phase 6: Notification Testing

### Server Ready

- [ ] Node.js server running (`npm run dev`)
- [ ] Terminal shows "VoIP Notification Server running on port 3000"
- [ ] No error messages

### Send Test Notification

- [ ] Retrieved device token from app
- [ ] Opened new terminal window
- [ ] Used curl/script to send notification with correct token:

  ```bash
  curl -X POST http://localhost:3000/send-to-token \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"YOUR_DEVICE_TOKEN\"}"
  ```

- [ ] Command executed without errors
- [ ] Server logs show: "Sent: 1" and "Failed: 0"

### Notification Received

- [ ] App was running in foreground
- [ ] Snackbar appeared with notification
- [ ] Notification also shown in list
- [ ] OR notification appeared in notification center (background/lock screen)

## ✅ Verification Checklist

### App Functionality

- [ ] Can copy token to clipboard
- [ ] Token displays without "Error:" prefix
- [ ] Snackbar animations work smoothly
- [ ] UI is readable and functional

### Server Functionality

- [ ] Health endpoint works: `GET /health`
- [ ] Register endpoint works: `POST /register-token`
- [ ] Send endpoint works: `POST /send-to-token`
- [ ] List tokens works: `GET /tokens`
- [ ] All responses are valid JSON

### Integration

- [ ] Device token from app matches what's sent to server
- [ ] Notification received within 2 seconds
- [ ] No errors in either logs
- [ ] Multiple notifications can be sent
- [ ] App receives all notifications

## 🐛 Debugging Checklist

If something doesn't work:

### Token Issues

- [ ] Checked `flutter run -v` verbose logs
- [ ] Confirmed GoogleService-Info.plist is added
- [ ] Verified Bundle ID matches everywhere
- [ ] Checked console for Firebase errors
- [ ] Restarted app

### Server Issues

- [ ] Checked port 3000 not in use: `netstat -ano | findstr :3000`
- [ ] Verified .p8 file exists in project root
- [ ] Checked credentials in index.js are correct
- [ ] Verified npm install completed without errors
- [ ] Restarted server with Ctrl+C then `npm run dev`

### Notification Issues

- [ ] Using physical device (not simulator)
- [ ] Device has internet connection
- [ ] Token copied exactly from app (no spaces)
- [ ] Verified in Firebase APNs is configured
- [ ] Checked Apple certificate is not expired
- [ ] Verified Bundle ID in APN matches app

## 📝 Documentation Review

- [ ] Read GETTING_STARTED.md
- [ ] Reviewed QUICKSTART.md
- [ ] Checked SETUP_GUIDE.md for your platform
- [ ] Understood API_EXAMPLES.sh endpoints
- [ ] Know where to find troubleshooting

## 🎉 Success Criteria

✅ **All of the following are true:**

1. Flutter app builds and runs on device
2. App displays FCM token (not error)
3. Token is copyable
4. Server starts without errors
5. Server health check responds
6. Notification sends without server errors
7. Device receives notification
8. Notification appears in app or notification center
9. Server logs show "Sent: 1, Failed: 0"

## 🆘 Getting Help

If items are not checked:

1. Which step is failing? (phases 1-6)
2. What's the error message?
3. Check that phase's troubleshooting in SETUP_GUIDE.md
4. Run verbose: `flutter run -v` or `npm run dev`
5. Review logs in console

## 📅 Timeline

- **Total Setup:** 45-60 minutes
- **Firebase Project:** 5 minutes
- **iOS Configuration:** 15 minutes
- **Flutter Setup:** 10 minutes
- **Server Setup:** 5 minutes
- **Testing:** 10-15 minutes

## 🔄 Recurring Checks

### Daily

- [ ] Device has internet
- [ ] Physical device available
- [ ] Token is still valid

### Weekly

- [ ] Apple certificate not expired
- [ ] Firebase credentials still valid
- [ ] Server runs without errors

### Before Production

- [ ] All checklist items completed
- [ ] Tested on multiple devices
- [ ] Error handling verified
- [ ] Security review done

---

**Status:** Ready for Testing ✅  
**Date Completed:** ___________  
**Tested By:** ___________  
**Notes:** ___________
