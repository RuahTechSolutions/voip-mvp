# iOS VoIP APN MVP

## Table of Contents

- Overview
- Architecture
- Components
- Prerequisites
- Apple Push Credentials
- Flutter App Setup
- Native iOS Bridge
- Node.js Push Server
- API Endpoints
- Testing Flow
- Troubleshooting
- Security Notes
- Next Steps
- Project Layout
- Helpful Scripts

## Overview

This workspace contains a Flutter-based iOS app that requests APN tokens through a native method channel and a Node.js server that delivers VoIP pushes with a certificate-based APN provider. The goal is a minimal path to test VoIP notifications without relying on any third-party push layers.

## Architecture

```
┌──────────────────────────┐          ┌────────────────────────────┐
│       Flutter App         │          │      Native iOS layer       │
│   (mobile_flutter/)       │          │   (AppDelegate.swift)       │
│ - Calls MethodChannel     │ ───────▶│ - Registers for APN tokens   │
│ - Displays token + logs   │          │ - Handles remote callbacks   │
└──────────────────────────┘          └────────────────────────────┘
                 │                                  │
                 │                                  ▼
                 │                        ┌────────────────────────┐
                 │                        │  Apple Push Notification │
                 │                        │        Service (APN)     │
                 │                        └────────────────────────┘
                 ▼
┌────────────────────────────────────────────────────────────────┐
│                       Node.js Push Server                       │
│                        (index.js + apn)                        │
│ - Reads device tokens mailed from the app                       │
│ - Sends voip notification with configured key                   │
│ - Exposes REST endpoints for register/send/query               │
└────────────────────────────────────────────────────────────────┘
```

## Components

- **mobile_flutter/**: Flutter UI, method channel, token display, and notification list.
- **ios/Runner/**: Swift files that call APN and return the token to Flutter.
- **index.js**: Express server that holds tokens, configures `apn.Provider`, and delivers pushes to APN with the `pushType` set to `voip`.
- **AuthKey_TXCPTLQB58.p8** (default) and **AuthKey_F22HR33BNR.p8**: Apple .p8 key files for the APN provider.
- **API_EXAMPLES.sh** / **test-server.bat**: Helper scripts for sending notifications from the command line.

## Prerequisites

- macOS with Xcode 12+ and a physical iOS device (VoIP pushes do not work on the simulator).
- Flutter SDK 3.3+ and Dart 3.3+.
- Node.js 14+ and npm/yarn installed.
- Apple Developer membership with permission to create APNs keys and enable VoIP push.

## Apple Push Credentials

1. Open the Apple Developer portal and create an APNs Auth Key (type VoIP).
2. Note the **Key ID** (e.g., `TXCPTLQB58`) and your **Team ID** (`LBA58EFBZF`).
3. Download the `.p8` file and place it in the repo root (replace the placeholder `AuthKey_TXCPTLQB58.p8` or `AuthKey_F22HR33BNR.p8` as needed).
4. Confirm the Node.js server uses the same `keyId`, `teamId`, and `key` file in the `configure()` helper inside `index.js`.
5. Ensure the APN topic is `com.ruah.voip.test.voip` so the notification matches the bundle ID plus `.voip`.

## Flutter App Setup

1. Open a terminal and run:

   ```bash
   cd mobile_flutter
   flutter clean
   flutter pub get
   ```

2. Plug in an iOS device, verify `flutter devices` lists it, then build:

   ```bash
   flutter run -d <device_id>
   ```

3. The app launches a single screen that requests an APN token via the method channel (`com.ruah.voip.test/apn`). The token appears in monospace text, can be copied with the button, and is logged to the console.
4. Keep the device connected while testing; the UI shows placeholder text until the token arrives.

## Native iOS Bridge

- Open `mobile_flutter/ios/Runner.xcworkspace` in Xcode.
- In the **Signing & Capabilities** tab for the Runner target:
  - Add **Push Notifications** capability.
  - Add **Background Modes** and enable **Remote notifications**.
- AppDelegate registers for remote notifications and stores the token:

  ```swift
  let apnChannel = FlutterMethodChannel(name: "com.ruah.voip.test/apn", binaryMessenger: controller.binaryMessenger)
  apnChannel.setMethodCallHandler { call, result in
      if call.method == "getAPNToken" {
          result(self.cachedToken ?? "token-not-ready")
      }
  }
  ```

- `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` converts the `Data` token to a 64-character hex string and caches it for the method channel.
- Notification callbacks (`didReceiveRemoteNotification`, `didFailToRegisterForRemoteNotificationsWithError`) log status and surface errors via `print` statements.

## Node.js Push Server

1. Install dependencies and start the server:

   ```bash
   npm install
   npm run dev
   ```

2. The server listens on port 3000 by default and prints the environment and registered token count.
3. `index.js` holds the following configuration block; update the pointers if you swap `.p8` files:

   ```javascript
   var options = {
       token: {
           key: "AuthKey_TXCPTLQB58.p8",
           keyId: "TXCPTLQB58",
           teamId: "LBA58EFBZF"
       },
       production: false
   };
   ```

4. The notification uses:
   - `note.topic = "com.ruah.voip.test.voip"`
   - `note.pushType = "voip"`
   - `note.payload` with a `voip: true` flag and placeholder `callId`/`from` values.
5. `deviceTokens` starts as a sample array; `POST /register-token` adds new values so you can send to your own device.

## API Endpoints

| Route | Description | Body | Example |
|-------|-------------|------|---------|
| `POST /register-token` | Save a new APN token | `{ "token": "<64 hex>" }` | `curl -X POST http://localhost:3000/register-token -H "Content-Type: application/json" -d "{ \"token\": \"<token>\" }"` |
| `POST /send-notification` | Send to all registered tokens | `{ "title": "Incoming Call", "body": "You have a call" }` | `curl -X POST http://localhost:3000/send-notification -H "Content-Type: application/json" -d "{ \"title\": \"Test\", \"body\": \"Hello\" }"` |
| `POST /send-to-token` | Target a single device | `{ "token": "<token>", "title": "", "body": "" }` | `curl -X POST http://localhost:3000/send-to-token -H "Content-Type: application/json" -d "{ \"token\": \"<token>\" }"` |
| `GET /tokens` | List all registered tokens | n/a | `curl http://localhost:3000/tokens` |
| `GET /health` | Server health and token count | n/a | `curl http://localhost:3000/health` |

## Testing Flow

1. Run the Flutter app on a device and wait for the APN token to appear. Tap the copy button or select the hex string.
2. Start the Node.js server (`npm run dev`). The console shows the default token count.
3. Use `curl`, `API_EXAMPLES.sh`, or `test-server.bat` to call `/send-to-token` with the token from step 1:

   ```bash
   curl -X POST http://localhost:3000/send-to-token \
     -H "Content-Type: application/json" \
     -d "{ \"token\": \"<your-token>\" }"
   ```

4. Watch the terminal for "Sent: 1" and "Failed: 0" and confirm the notification appears on the device (foreground or background).
5. Register the same token via `/register-token` if you want to broadcast to multiple devices later.

## Troubleshooting

- **MethodChannel throws MissingPluginException**: Rebuild the app (`flutter clean` + `flutter run`). Verify AppDelegate registers the channel before `GeneratedPluginRegistrant`.
- **Token stays 'Not initialized' or contains an error**: Ensure the device is unlocked, internet-connected, and Push Notifications capability is enabled. Restart the app.
- **Notifications never arrive**: Check the console for `note.failed`, confirm the token matches the device, and verify the `.p8` file still lives in the repo. Inspect `apns` logs (if any) and make sure the Apple certificate is valid.
- **Server refuses to start**: Ensure port 3000 is free (`netstat -ano | findstr :3000`). Restart the terminal, delete `node_modules`, and re-run `npm install` if dependencies are corrupted.
- **Token mismatch**: Always copy the token from the Flutter UI after the APN request completes; the token is 64 hexadecimal characters.

## Security Notes

- Treat the `.p8` files as secrets; do not push them to public repositories.
- Rotate the APN key in Apple Developer if you suspect compromise.
- Switch `production` to `true` in `index.js` when sending to TestFlight or App Store builds.
- Keep the server behind HTTPS and restrict incoming requests to trusted networks once you move beyond local testing.

## Next Steps

1. Persist tokens in a database so you can target groups of devices.
2. Add CallKit integration for a native incoming call UI when pushes arrive.
3. Plug in real call data over WebRTC or SIP instead of the placeholder payload.
4. Harden error handling and retry logic inside `sendNotification`.
5. Automate token registration via a secure backend if the app will scale beyond manual testing.

## Project Layout

```
ios_voip/
├── mobile_flutter/          # Flutter app, method channel, token UI
├── index.js                 # Express + APN server
├── AuthKey_*.p8             # Apple keys for APN authentication
├── API_EXAMPLES.sh          # Curl examples for every endpoint
├── test-server.bat          # Windows helper script (batch)
└── README.md                # This file
```

## Helpful Scripts

- `API_EXAMPLES.sh`: Run this shell script to exercise each endpoint with sample data.
- `test-server.bat`: Windows-friendly script for sending notification payloads without typing raw curl commands.

Running these scripts after you start the server allows you to confirm the connection, payload format, and token lifecycle in one pass.
