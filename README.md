# Citizen Mobile App (Flutter)

This is the Citizen app for the Civic Issue Reporting & Tracking System.

## Run Steps

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the application:

   **For Android Emulator:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=USE_MOCK=false
   ```

   **For Real Phone / Real Device:**
   Make sure your phone and laptop are on the same Wi-Fi. Replace `<laptop-LAN-IP>` with your machine's IP (e.g. `192.168.1.5`).
   ```bash
   flutter run --dart-define=API_BASE_URL=http://<laptop-LAN-IP>:8000/api --dart-define=USE_MOCK=false
   ```

## Mock Mode

While the Backend is not ready, you can run the app with mock mode enabled:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=USE_MOCK=true
```
This forces the application to load JSON mock files directly from `lib/mock/` instead of reaching out to the live server. Note: you'll need to drop the mock payloads inside `lib/mock/` matching the API documentation.

## Permissions

* **Android:** 
  The app has `INTERNET`, `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, and `READ_EXTERNAL_STORAGE` enabled in `AndroidManifest.xml`. Also `android:usesCleartextTraffic="true"` is added.
* **iOS:**
  `Info.plist` is configured with `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, and `NSAppTransportSecurity` (to allow local networking).

## TODO(contract) Items Raised

*(None so far. All rules and enums accurately mapped.)*
