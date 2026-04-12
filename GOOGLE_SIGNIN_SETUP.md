# Google Sign-In Firebase Setup Guide

## Issues Fixed in Code:
✅ Better error handling in `auth_provider.dart`  
✅ Added console logging to debug issues  
✅ Added proper scopes for Google Sign-In  
✅ Better distinction between user cancellation and actual errors  

---

## Step-by-Step Setup Instructions:

### **1. Firebase Console Configuration**

#### For **Web** Platform:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **library-management-94164**
3. Navigate to **Authentication** → **Sign-in method** → **Google**
4. Make sure Google is **enabled**
5. Go to **Project Settings** → **Service Accounts**
6. Check that your Web app is registered

#### For **Android** Platform:
1. In Firebase Console, go to **Authentication** → **Sign-in method** → **Google**
2. Copy the **Web Client ID** and **Android Client ID** from the Google Cloud Console
3. Click on **Google Cloud Console** link in Firebase
4. Go to **Credentials**
5. Create OAuth 2.0 credentials for Android if not present:
   - Application type: **Android**
   - Package name: **com.example.library_management** (check in `android/app/build.gradle`)
   - SHA-1: Get this by running:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Copy the SHA-1 value and paste in Firebase Console

#### For **iOS** Platform:
1. Bundle ID should match your iOS app bundle ID
2. Usually configured automatically if you have google-services.json

---

### **2. Android Configuration**

#### Update `android/app/build.gradle`:
```gradle
android {
    ...
    defaultConfig {
        applicationId "com.example.library_management"
        minSdkVersion 21  // Google Sign-In requires this
        targetSdkVersion 33
        ...
    }
}
```

#### Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <application ...>
        <!-- Activities -->
    </application>
</manifest>
```

---

### **3. Web Configuration**

#### For **Chrome** Platform (Web):
1. No additional setup needed if you've already configured Google OAuth in Firebase
2. Google Sign-In on web works automatically via Firebase Web SDK

#### Known Web Issues:
- **Pop-up blocked**: Make sure pop-ups are allowed
- **CORS issues**: Ensure your domain is whitelisted in Google Cloud Console
- **localhost**: Should work automatically

---

### **4. Testing the Implementation**

#### Option A: Run on Web (Easiest)
```bash
flutter run -d chrome
```
- Click "Continue with Google" or "Sign Up with Google"
- A Google sign-in window should appear
- Select an account and authorize

#### Option B: Test on Android Emulator
```bash
flutter run -d emulator-5554
```
**Note**: Make sure you've:
- Added SHA-1 to Firebase Console
- Installed Google Play Services on emulator

#### Option C: Test on Physical Android Device
```bash
flutter run -d <device_id>
```
- Same requirements as emulator

---

### **5. Troubleshooting**

#### **Error: "Google login failed" with no details**
- **Check Firebase Console**: Ensure Google is enabled in Authentication
- **Check logs**: Look at console output for detailed error messages
- **Restart app**: Close and restart after changing Firebase settings

#### **Error: "User cancelled the sign-in"**
- **This is normal**: User closed the Google sign-in popup
- **No error in UI**: The app still shows the login screen

#### **Error: "E/LoggingAnalytics: Failed to initialize Firebase Analytics"**
- **Not critical**: Google Sign-In will still work
- **Solution**: Ensure `google-services.json` is in `android/app/`

#### **Android Emulator Not Working**
```bash
# Check if Google Play Services is installed
# Also try updating Google Play Services in emulator
flutter pub get
flutter clean
flutter run
```

#### **Web Not Working (Pop-up Block)**
1. Allow pop-ups in Chrome settings
2. Check browser console (F12) for errors
3. Ensure you're using `localhost` or registered domain

---

### **6. Verify Installation**

Run this to check if dependencies are properly installed:
```bash
flutter pub get
flutter doctor -v
```

Expected output should show:
- ✓ Google Sign-In plugin
- ✓ Firebase Auth
- ✓ Cloud Firestore

---

### **7. Environment Variables**

No manual environment variables needed if:
- ✓ `google-services.json` is in `android/app/`
- ✓ `GoogleService-Info.plist` is in `ios/Runner/`
- ✓ Firebase Console is properly configured

---

## Quick Checklist:

- [ ] Firebase Console: Google Sign-In enabled
- [ ] Android: SHA-1 fingerprint added to Firebase
- [ ] Android: `google-services.json` downloaded and placed in `android/app/`
- [ ] iOS: `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Dependencies: `flutter pub get` run successfully
- [ ] Code: Check console logs for detailed error messages

---

## Debug Output Expected:

When you click "Continue with Google", you should see in console:
```
I/System.out: Google user signed in: user@gmail.com
I/System.out: Firebase user created/signed in: user@gmail.com
```

If you see errors, post them in the debug console!

---

## Still Not Working?

1. **Check Firebase Console** - Ensure all credentials are correct
2. **Check androidmanifest.xml** - Ensure internet permission is there
3. **Check google-services.json** - Make sure it's the latest version
4. **Clean & Rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
5. **Check Console Logs** - Look for specific error messages in the debug output
