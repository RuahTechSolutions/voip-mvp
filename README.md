# iOS VoIP Flutter App - Complete Setup

A minimal viable product (MVP) for iOS VoIP push notifications using Flutter and Node.js.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [What's Included](#whats-included)
- [System Requirements](#system-requirements)
- [Detailed Setup](#detailed-setup)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)

## 🎯 Overview

This project demonstrates:

- ✅ VoIP token generation in Flutter
- ✅ Push notification reception on iOS
- ✅ Server-side notification delivery via APN
- ✅ Token registration and management
- ✅ Simple REST API for testing

**Bundle ID:** `com.ruah.voip.test`

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS Device                            │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Flutter App (mobile_flutter/)                        │   │
│  │                                                        │   │
│  │  • Initializes Firebase on startup                   │   │
│  │  • Requests notification permissions                 │   │
│  │  • Gets FCM token from Firebase                      │   │
│  │  • Displays token in UI                              │   │
│  │  • Listens for notifications                         │   │
│  │  • Shows received notifications                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                   Firebase Cloud Service
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Apple Push Notification                  │
│                   (APN) Infrastructure                       │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │
                   HTTP REST API
                            │
┌─────────────────────────────────────────────────────────────┐
│                  Node.js Server                              │
│                   (index.js)                                 │
│                                                               │
│  • Express.js API server                                    │
│  • Connects to APN with credentials                         │
│  • Manages registered device tokens                         │
│  • Routes:                                                  │
│    - POST /register-token                                   │
│    - POST /send-notification                               │
│    - POST /send-to-token                                   │
│    - GET /tokens                                           │
│    - GET /health                                           │
└─────────────────────────────────────────────────────────────┘
```

## 📦 What's Included

### Flutter App (`mobile_flutter/`)

- **lib/main.dart** - Main app with VoIP UI
  - Token display
  - Copy to clipboard
  - Notification history
  - Real-time notification handling

- **lib/firebase_options.dart** - Firebase configuration
  - Platform-specific settings
  - Project credentials

- **ios/Runner/Info.plist** - iOS configuration
  - Bundle ID setup
  - Notification permissions

- **pubspec.yaml** - Dependencies
  - firebase_core
  - firebase_messaging
  - uuid

### Server (`index.js`)

- Express.js REST API
- APN integration with certificate-based auth
- Token management
- Multiple send endpoints
- Proper error handling

### Documentation

- **SETUP_GUIDE.md** - Complete setup instructions
- **QUICKSTART.md** - Quick reference guide
- **README.md** - This file
- **test-server.bat** - Windows testing script

### Credentials

- **AuthKey_F22HR33BNR.p8** - Apple authentication key
  - Key ID: F22HR33BNR
  - Team ID: 3756UBXGBX

## 💻 System Requirements

### For iOS Development

- **macOS** with Xcode 12+
- **Xcode Command Line Tools**
- **CocoaPods** (comes with Flutter)
- **iOS 10.0+** as deployment target

### For Flutter

- **Flutter SDK 3.3.0+**
- **Dart 3.3.0+**
- **Device** iOS 10 or later (physical device required for testing)

### For Server

- **Node.js 14+**
- **npm or yarn**
- **Apple authentication key** (.p8 file)

## 📖 Detailed Setup

### Phase 1: Prepare Your Apple Credentials

**You already have this:**

- File: `AuthKey_F22HR33BNR.p8`
- Key ID: `F22HR33BNR`
- Team ID: `3756UBXGBX`

Keep this file secure and never commit it to public repositories.

### Phase 2: Set Up Firebase Project

1. **Go to Firebase Console:**
   - Visit <https://console.firebase.google.com/>
   - Create a new project or select existing

2. **Create iOS App:**
   - Click "Add app" → iOS
   - Bundle ID: `com.ruah.voip.test`
   - App Store ID: (optional)
   - Team ID: `3756UBXGBX`
   - Download `GoogleService-Info.plist`

3. **Save Configuration:**
   - Keep the `GoogleService-Info.plist` file
   - You'll add it to Xcode later

### Phase 3: Configure APNs Certificate

1. **In Firebase Console:**
   - Go to Project Settings → Cloud Messaging
   - Scroll to iOS app configuration
   - Click "Upload" for APNs Authentication Key
   - Upload your .p8 key file
   - You may need to generate this in Apple Developer account

2. **Verify Settings:**
   - APNs Key ID: `F22HR33BNR`
   - Team ID: `3756UBXGBX`
   - Bundle ID: `com.ruah.voip.test`

### Phase 4: Set Up Flutter App

```bash
# Navigate to Flutter app
cd mobile_flutter

# Get dependencies
flutter pub get

# Update Firebase options
# Edit lib/firebase_options.dart with your Firebase credentials
```

### Phase 5: Configure Xcode Project

1. **Open Xcode:**

   ```bash
   open ios/Runner.xcworkspace
   ```

   **Note:** Use `.xcworkspace`, NOT `.xcodeproj`

2. **Add GoogleService-Info.plist:**
   - Drag `GoogleService-Info.plist` into Xcode
   - Ensure it's added to "Runner" target only
   - Copy items if needed

3. **Enable Capabilities:**
   - Select "Runner" project
   - Select "Runner" target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes"
     - Select "Remote notifications"
     - Select "Background fetch"

4. **Set Bundle Identifier:**
   - Verify Bundle Identifier is `com.ruah.voip.test`
   - Verify Team ID is set correctly

5. **Configure Signing:**
   - Select Team for signing
   - Ensure certificate is valid

### Phase 6: Update firebase_options.dart

```dart
// Replace placeholder values with your Firebase project info
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY',           // From GoogleService-Info.plist
  appId: 'YOUR_IOS_APP_ID',             // From GoogleService-Info.plist
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From GoogleService-Info.plist
  projectId: 'YOUR_PROJECT_ID',         // From GoogleService-Info.plist
  databaseURL: 'YOUR_DATABASE_URL',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  iosBundleId: 'com.ruah.voip.test',
);
```

### Phase 7: Deploy to Device

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Or let Flutter choose
flutter run
```

**Wait for app to fully load** - This takes a minute on first run.

### Phase 8: Set Up Node.js Server

```bash
# In project root (ios_voip/)
npm install
```

This installs:

- `apn` - Apple Push Notification library
- `express` - Web framework
- `nodemon` - Auto-reload during development

## 🚀 Testing Workflow

### Step 1: Get Device Token

1. Launch the Flutter app on physical iOS device
2. Wait for "VoIP Token Information" to show
3. Copy the FCM Token from the UI
4. Save it somewhere (you'll need it for testing)

### Step 2: Start Server

```bash
npm run dev
```

Output should show:

```
VoIP Notification Server running on port 3000
Environment: production
Registered tokens: 1
```

### Step 3: Send Test Notification

**Option A: Using curl (Windows)**

```bash
curl -X POST http://localhost:3000/send-to-token ^
  -H "Content-Type: application/json" ^
  -d "{\"token\":\"YOUR_DEVICE_TOKEN_HERE\"}"
```

**Option B: Using test script**

```bash
test-server.bat
```

**Option C: Using PowerShell**

```powershell
$body = @{
    token = "YOUR_DEVICE_TOKEN_HERE"
    title = "Test Call"
    body = "Test Notification"
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:3000/send-to-token `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

### Step 4: Verify

- **App Running:** Snackbar appears with notification
- **App in Background:** Notification appears in notification center
- **App Closed:** Notification still received (handled by iOS)

Check server logs:

```
Sent: 1
Failed: 0
```

## 📡 API Endpoints

### 1. Register Token

Register a device token for future notifications.

```http
POST /register-token
Content-Type: application/json

{
  "token": "device_token_here"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Token registered",
  "tokens": 1
}
```

### 2. Send to Specific Token

Send a notification to a specific device.

```http
POST /send-to-token
Content-Type: application/json

{
  "token": "device_token_here",
  "title": "Incoming Call",
  "body": "You have an incoming VoIP call"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Notification sent",
  "token": "device_token_here"
}
```

### 3. Send to All Devices

Send a notification to all registered tokens.

```http
POST /send-notification
Content-Type: application/json

{
  "title": "System Announcement",
  "body": "All devices receive this message"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Notification sent to 3 device(s)",
  "count": 3
}
```

### 4. List Tokens

Get all registered device tokens.

```http
GET /tokens
```

**Response:**

```json
{
  "count": 2,
  "tokens": [
    "token_1_here",
    "token_2_here"
  ]
}
```

### 5. Health Check

Check if server is running.

```http
GET /health
```

**Response:**

```json
{
  "status": "ok",
  "registeredTokens": 2
}
```

## 🧪 Testing

### Manual Testing

1. **Get Token:**
   - Run app
   - Copy token from UI

2. **Send Notification:**
   - Use curl/script with token
   - Check server logs

3. **Verify Receipt:**
   - Check app UI
   - Check device notification center

### Batch Testing

Register multiple tokens:

```bash
curl -X POST http://localhost:3000/register-token ^
  -H "Content-Type: application/json" ^
  -d "{\"token\":\"token_1\"}"

curl -X POST http://localhost:3000/register-token ^
  -H "Content-Type: application/json" ^
  -d "{\"token\":\"token_2\"}"

curl -X POST http://localhost:3000/send-notification ^
  -H "Content-Type: application/json" ^
  -d "{}"
```

### Performance Testing

Server can handle:

- Multiple devices (limited by APN)
- Concurrent notifications
- Immediate token registration

Current setup supports typical small-scale testing.

## 🔧 Troubleshooting

### 🔴 "Device token is Not initialized"

**Causes:**

- Firebase not initialized
- User denied permissions
- GoogleService-Info.plist missing

**Solutions:**

```bash
# 1. Check logs
flutter run -v

# 2. Verify plist is in Xcode
# Open ios/Runner.xcworkspace in Xcode
# Check Runner target has GoogleService-Info.plist

# 3. Check bundle ID matches
# Xcode → Runner → General → Bundle Identifier
# Should be: com.ruah.voip.test

# 4. Retry app
# Stop app with Ctrl+C
# Run again: flutter run
```

### 🔴 Notifications Not Received

**Causes:**

- Using iOS Simulator (doesn't support push)
- Wrong device token sent
- APNs certificate not uploaded
- Device offline

**Solutions:**

```bash
# 1. Use physical device only
flutter devices  # should show real iOS device

# 2. Verify token matches
# Get token from app UI
# Use exact token in API call

# 3. Check Firebase Cloud Messaging
# Console → Cloud Messaging → APNs

# 4. Check network
# Device should have WiFi/cellular connection
```

### 🔴 Server Won't Start

**Error:** Port 3000 already in use

```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process (replace PID)
taskkill /PID 1234 /F

# Try again
npm run dev
```

**Error:** Module not found

```bash
# Install dependencies
npm install

# Verify
npm list apn express
```

### 🔴 "Failed to get token" in Logs

**Causes:**

- GoogleService-Info.plist wrong
- Firebase project mismatch
- Bundle ID mismatch

**Solutions:**

```dart
// Check firebase_options.dart
// Ensure iosBundleId = 'com.ruah.voip.test'

// Verify from GoogleService-Info.plist:
// BUNDLE_ID matches com.ruah.voip.test
// PROJECT_ID is correct
```

### 🔴 "Failed: ..." in Server Logs

**Check token validity:**

```bash
# Get tokens
curl http://localhost:3000/tokens

# Verify token format
# Should be 64 hex characters (256 bits)

# Re-register token
curl -X POST http://localhost:3000/register-token \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"new_token_from_app\"}"
```

## 📁 Project Structure

```
ios_voip/
├── AuthKey_F22HR33BNR.p8          # Apple APNs key (KEEP SECRET!)
├── index.js                         # Node.js server (Express + APN)
├── package.json                     # Server dependencies
├── package-lock.json                # Dependency lock file
├── test-server.bat                  # Windows testing script
├── SETUP_GUIDE.md                   # Detailed setup instructions
├── QUICKSTART.md                    # Quick reference
├── README.md                        # This file
│
└── mobile_flutter/                  # Flutter app
    ├── lib/
    │   ├── main.dart               # App UI and notification logic
    │   └── firebase_options.dart    # Firebase configuration
    ├── ios/
    │   ├── Runner/
    │   │   ├── AppDelegate.swift
    │   │   ├── GeneratedPluginRegistrant.h
    │   │   ├── GeneratedPluginRegistrant.m
    │   │   └── Info.plist          # iOS app config (bundle ID, etc)
    │   ├── Runner.xcodeproj/        # Xcode project
    │   └── Runner.xcworkspace/      # Xcode workspace (use this!)
    ├── pubspec.yaml                 # Flutter dependencies
    ├── pubspec.lock                 # Dependency lock file
    ├── test/                        # Flutter unit tests
    └── android/                     # Android setup (not used in this MVP)
```

## 🔐 Security Notes

- **Keep `.p8` file secure** - Never commit to public repos
- **Use environment variables** for production
- **Regenerate keys** if compromised
- **Use HTTPS** in production
- **Validate tokens** on server

## 📚 Additional Resources

- [Firebase Setup for Flutter](https://firebase.flutter.dev/docs/overview/)
- [Apple Push Notification Documentation](https://developer.apple.com/notifications/)
- [CallKit Framework](https://developer.apple.com/documentation/callkit) (for next phase)
- [VoIP Push Notifications](https://developer.apple.com/documentation/pushkit) (advanced)
- [Flutter Documentation](https://flutter.dev/docs)

## 🚀 Next Steps

### To Extend This MVP

1. **Implement CallKit** - Native iOS call UI
2. **Add WebRTC** - Audio/video streaming
3. **User Authentication** - Secure token verification
4. **Database Backend** - Persistent storage
5. **Call Management** - Accept/reject UI
6. **SIP/VOIP Protocol** - Real call handling
7. **Scaling** - AWS Lambda, cloud functions

## 📝 Notes

- This is an MVP - not production-ready
- Token format: hex string (64 characters)
- Notifications expire in 1 hour
- Server handles concurrent requests
- SQLite recommended for local storage
- Consider Firebase Realtime Database for tokens

## 📞 Support

For issues:

1. Check TROUBLESHOOTING section
2. Review Flutter logs: `flutter run -v`
3. Check server logs: `npm run dev`
4. Verify all configuration steps completed
