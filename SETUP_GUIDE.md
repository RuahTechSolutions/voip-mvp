# iOS VoIP Flutter App - MVP

This is a basic MVP Flutter application for iOS VoIP functionality with Firebase Cloud Messaging (FCM) integration.

## Features

- Generate and display VoIP/FCM tokens
- Receive and display push notifications
- Copy token to clipboard for easy sharing
- Foreground and background notification handling

## Project Structure

```
ios_voip/
├── AuthKey_F22HR33BNR.p8        # Apple authentication key for APN
├── index.js                      # Node.js server for sending notifications
├── package.json                  # Node.js dependencies
└── mobile_flutter/               # Flutter app
    ├── lib/
    │   ├── main.dart            # Main app with VoIP token management UI
    │   └── firebase_options.dart # Firebase configuration
    ├── pubspec.yaml             # Flutter dependencies
    └── ios/
        └── Runner/
            └── Info.plist       # iOS app configuration
```

## Setup Instructions

### 1. Flutter App Setup

#### Prerequisites

- Flutter SDK installed
- Xcode installed (for iOS)
- Firebase project created
- Apple Developer account with signing certificates

#### Steps

1. **Navigate to the Flutter app:**

   ```bash
   cd mobile_flutter
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase (iOS):**
   - Download your Firebase GoogleService-Info.plist file
   - Open the iOS project in Xcode:

     ```bash
     open ios/Runner.xcworkspace
     ```

   - Drag and drop GoogleService-Info.plist into Xcode under Runner
   - Make sure it's added to the Runner target

4. **Update firebase_options.dart:**
   - Replace placeholder values with your Firebase project credentials
   - Ensure the iOS bundle ID is `com.ruah.voip.test`

5. **Enable Push Notifications in Xcode:**
   - In Xcode, select Runner project
   - Go to Signing & Capabilities
   - Add "Push Notifications" capability
   - Add "Background Modes" capability with:
     - Remote notifications
     - Background fetch

6. **Configure APNs (Apple Push Notification service):**
   - In your Apple Developer account, create an APNs certificate
   - In Firebase Console:
     - Go to Project Settings → Cloud Messaging
     - Upload your APNs certificate under iOS app configuration
     - Add the Team ID and Bundle ID

### 2. Server Setup (Node.js)

The Node.js server uses APN (Apple Push Notification) to send notifications to devices.

#### Setup

1. **Install dependencies:**

   ```bash
   npm install
   ```

2. **Configure the server:**
   - Ensure `AuthKey_F22HR33BNR.p8` is in the project root
   - Update `index.js` with your Apple credentials:
     - Key ID: `F22HR33BNR` (from your .p8 filename)
     - Team ID: `3756UBXGBX`

3. **Update device token:**
   - Run the Flutter app and copy the device token from the app UI
   - Replace the `deviceToken` variable in `index.js` with the token from the app

4. **Send a notification:**

   ```bash
   npm run dev
   ```

## How It Works

### Token Generation Flow

1. **App Launch:** The Flutter app initializes Firebase Messaging on startup
2. **Permission Request:** The app requests notification permissions from the user
3. **Token Generation:** Firebase generates a unique FCM token for the device
4. **Display:** The token is displayed in the app UI and can be copied

### Notification Flow

1. **Server sends APN:** Node.js server sends a notification via APN
2. **iOS receives notification:** iOS delivers the notification to the app
3. **App displays:** Flutter app displays the notification in the UI
4. **Foreground handling:** If app is open, a snackbar shows the notification

## Testing

### 1. Get the Device Token

- Run the Flutter app on a physical device
- Copy the FCM token shown in the app

### 2. Send a Test Notification

- Update the `deviceToken` in `index.js` with the copied token
- Run `npm run dev` to send a notification

### 3. Verify

- Check if the notification appears in the app
- Check the console logs for confirmation

## Important Notes

⚠️ **VoIP vs Regular Push Notifications:**

- This implementation uses Firebase Cloud Messaging (FCM) for iOS
- For true VoIP calls, you would need to implement CallKit with VoIP push notifications
- VoIP push notifications are different from regular APNs and require additional setup

⚠️ **Real Device Required:**

- Push notifications cannot be tested on the iOS simulator
- You must use a physical iOS device

⚠️ **Bundle ID:**

- Make sure the bundle ID matches across:
  - Xcode project settings
  - Firebase console
  - Apple Developer account

## File Descriptions

### index.js

Node.js server that sends APN notifications using the `apn` package.

- Configures APN provider with authentication key
- Sends notifications to a specific device token
- Handles APN responses

### lib/main.dart

Main Flutter app implementing:

- Firebase initialization
- Token generation and display
- Notification listening
- UI for viewing tokens and notifications

### firebase_options.dart

Firebase configuration file with platform-specific settings.

## Troubleshooting

### Device token is "Not initialized"

- Check if user granted notification permissions
- Verify Firebase is properly configured
- Check logs for Firebase initialization errors

### Notifications not received

- Verify the device token in the app matches what's sent to server
- Check if APNs certificate is uploaded in Firebase console
- Ensure app is properly signed
- Check device is on same network and has internet

### "Failed to get token" error

- Verify GoogleService-Info.plist is properly added to Xcode project
- Check Firebase project ID matches in firebase_options.dart
- Ensure device has internet connection

## Next Steps

To extend this MVP:

- Implement CallKit for native VoIP call experience
- Add user authentication
- Store tokens in a database
- Add call handling logic
- Implement UI for making/receiving calls
- Add WebRTC for audio/video streaming
