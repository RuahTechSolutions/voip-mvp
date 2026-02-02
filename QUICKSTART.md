# iOS VoIP App - Quick Start Guide

This guide helps you quickly set up and test the VoIP functionality.

## What You Have

✅ **Flutter App** (`mobile_flutter/`)

- Displays VoIP/FCM tokens
- Shows received notifications
- Runs on iOS

✅ **Node.js Server** (`index.js`)

- Sends push notifications via APN
- REST API endpoints for managing tokens
- Token registration system

## Quick Setup

### Step 1: Update Node.js Dependencies

```bash
npm install
```

### Step 2: Prepare Your Apple Credentials

- You already have `AuthKey_F22HR33BNR.p8`
- Verify your Team ID is correct: `3756UBXGBX`
- Keep this file secure!

### Step 3: Set Up Firebase (First Time Only)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing
3. Create an iOS app with Bundle ID: `com.ruah.voip.test`
4. Download `GoogleService-Info.plist`
5. In Flutter project, open `ios/Runner.xcworkspace` in Xcode
6. Add the `.plist` file to the Runner target

### Step 4: Add APNs Certificate to Firebase

1. In Firebase Console → Project Settings → Cloud Messaging
2. Upload your APNs Certificate (you may need to generate one in Apple Developer)
3. Set Bundle ID: `com.ruah.voip.test`
4. Set Team ID: `3756UBXGBX`

### Step 5: Update Firebase Config

Edit `mobile_flutter/lib/firebase_options.dart` and replace placeholder values with your Firebase credentials.

### Step 6: Build and Run

```bash
cd mobile_flutter
flutter pub get
flutter run -d <device_id>
```

Replace `<device_id>` with your iOS device ID (use `flutter devices` to list)

## Testing Workflow

### 1. Get Device Token

- Run the app on a physical iOS device
- Wait for the token to appear
- Copy the FCM token from the app UI

### 2. Start the Server

```bash
npm run dev
```

The server runs on `http://localhost:3000`

### 3. Send a Notification

In another terminal:

```bash
curl -X POST http://localhost:3000/send-to-token \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"YOUR_FCM_TOKEN_HERE\"}"
```

Replace `YOUR_FCM_TOKEN_HERE` with the token from Step 1.

### 4. Check the App

- If the app is running, you should see a snackbar notification
- The notification will also be added to the "Received Notifications" list

## Available API Endpoints

### Register a Device Token

```bash
POST /register-token
{
  "token": "device_token_here"
}
```

### Send to All Registered Devices

```bash
POST /send-notification
{
  "title": "Optional Title",
  "body": "Optional message body"
}
```

### Send to Specific Device

```bash
POST /send-to-token
{
  "token": "specific_device_token",
  "title": "Optional Title",
  "body": "Optional message body"
}
```

### List All Registered Tokens

```bash
GET /tokens
```

### Health Check

```bash
GET /health
```

## Important: Real Device Required ⚠️

- iOS Simulator **CANNOT** receive push notifications
- You **MUST** use a physical iOS device
- Device must have iOS 10 or later
- Must be connected to internet

## Troubleshooting

### "Device token is not initialized"

- ❌ App hasn't started Firebase properly
- ✅ Check console for Firebase errors
- ✅ Verify GoogleService-Info.plist is added

### "Notifications not received"

- ❌ Using simulator (won't work)
- ❌ Device token doesn't match what was sent
- ❌ APNs certificate not configured
- ✅ Check server logs for errors
- ✅ Verify device is connected to internet

### Server fails to start

```bash
# Clear old processes if needed
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### "Failed to get token"

- ❌ Firebase not initialized
- ✅ Check GoogleService-Info.plist
- ✅ Verify bundle ID matches everywhere

## File Reference

| File | Purpose |
|------|---------|
| `index.js` | Node.js server for sending notifications |
| `AuthKey_F22HR33BNR.p8` | Apple authentication key for APN |
| `mobile_flutter/lib/main.dart` | Flutter app UI and notification logic |
| `mobile_flutter/lib/firebase_options.dart` | Firebase configuration |
| `mobile_flutter/ios/Runner/Info.plist` | iOS app settings |

## Next Steps

Once basic VoIP is working:

1. **Add CallKit Integration** - For native call experience
2. **Add WebRTC** - For actual audio/video
3. **User Authentication** - Verify device ownership
4. **Database** - Store tokens persistently
5. **Call UI** - Build call accept/reject interface

## Additional Resources

- [Flutter Firebase Docs](https://firebase.flutter.dev/)
- [APN Documentation](https://developer.apple.com/notifications/)
- [CallKit Integration](https://developer.apple.com/documentation/callkit)
- [VoIP Push Notifications](https://developer.apple.com/documentation/pushkit)
