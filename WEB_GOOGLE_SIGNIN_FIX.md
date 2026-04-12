# Web Google Sign-In Issues - Complete Fix Guide

## ⚠️ Common Reasons Google Sign-In Fails on Web

### **1. Pop-ups are BLOCKED (Most Common) ⚠️**
**Symptoms:** Button doesn't respond or does nothing  
**Fix:**
```
Chrome Settings → Privacy and Security → Site Settings
→ Pop-ups and redirects → Allow for localhost:5000
```

### **2. Firebase Web Configuration Missing**
**Symptoms:** Error about CORS or configuration not found  
**Fix:**
```
1. Go to https://console.firebase.google.com
2. Select your project: library-management-94164
3. Go to Project Settings (gear icon)
4. Click "Web App" or add one if missing
5. Copy the config
6. Verify it has: apiKey, authDomain, projectId
```

### **3. Google OAuth Not Configured for Web**
**Symptoms:** "400: invalid_request" or CORS errors  
**Fix:**
```
1. Firebase Console → Authentication → Sign-in method
2. Click Google (should be enabled - green toggle)
3. If not, click Google → Enable it
4. Save
```

---

## Step-by-Step Web Setup for Google Sign-In

### **Step 1: Chrome Settings (Allow Pop-ups)**
```
1. Open Chrome
2. Click three dots (top right) → Settings
3. Privacy and security → Site settings
4. Pop-ups and redirects
5. Add localhost:5000 to Allow list
6. Close and refresh page
```

### **Step 2: Firebase Console Configuration**
```
1. Open https://console.firebase.google.com
2. Click your project name
3. Go to Settings (gear icon) → Project settings
4. Find Web app in Authorized domains
5. Make sure these are there:
   - localhost:5000
   - localhost:5001  
   - 127.0.0.1:5000
```

### **Step 3: Google Cloud Console**
```
1. Firebase Console → Settings → Project Settings
2. Click "Google Cloud Console" link
3. Left menu → APIs & Services → Credentials
4. Find OAuth 2.0 Client ID for Web (should say "Web application")
5. Click it and check:
   - Authorized redirect URIs include:
     - http://localhost:5000
     - http://localhost:5001
6. If not, add them:
   - Click "Edit"
   - Add URIs
   - Click Save
```

---

## Testing the Fix

### **Test 1: Check Pop-ups Work**
```
1. Open https://www.google.com
2. Try signing in with Google somewhere
3. Pop-up should open smoothly
4. If blocked, allow it in browser settings
```

### **Test 2: Run Flutter Web App**
```bash
flutter run -d chrome
```

### **Test 3: Open Browser Console (F12)**
```
1. In Chrome, press F12
2. Go to Console tab
3. Click Google Sign-In button
4. Watch console messages
5. Copy any red error messages
```

### **Test 4: Expected Console Output**
**Good output:**
```
Starting Google Sign-in...
Firebase user signed in: yourname@gmail.com
```

**Bad output (something went wrong):**
```
Starting Google Sign-in...
[RED ERROR] Auth...
```

---

## Troubleshooting by Error Message

### **Error: "User cancelled the sign-in"**
**This is NORMAL!** User closed the Google popup
- Just click the button again
- Not actually an error

---

### **Error: "Pop-ups blocked"**
**Fix:**
```
Chrome → Settings → Privacy & Security → Site settings
→ Pop-ups and redirects → Allow localhost:5000
```

---

### **Error: "CONFIGURATION_NOT_FOUND"**
**Reasons:**
- Google Sign-In not enabled in Firebase Console
- Web app not registered in Firebase

**Fix:**
1. Firebase Console → Authentication → Sign-in method
2. Click Google (enable with toggle)
3. Save changes
4. Refresh the app

---

### **Error: "CORS error" or "400: invalid_request"**
**Reasons:**
- Redirect URI not configured in Google Cloud Console
- Domain not authorized

**Fix:**
1. Google Cloud Console → APIs & Services → Credentials
2. Click OAuth client ID (Web application)
3. Add these to "Authorized redirect URIs":
   - http://localhost:5000
   - http://localhost:5001
   - http://127.0.0.1:5000
4. Save and refresh app

---

### **Error: "ERR_NETWORK"**
**Reasons:**
- Internet connection lost
- Network firewall blocking

**Fix:**
```
1. Check internet connection
2. Restart browser
3. Try with mobile hotspot if WiFi blocked
4. Check firewall settings
```

---

### **Error: Message about certificate or HTTPS**
**Reasons:**
- Localhost requires HTTP (not HTTPS) by default

**Fix:**
```bash
# Don't use HTTPS on localhost
flutter run -d chrome
# This will run on http://localhost:5000 (correct)

# NOT on https://localhost:5000 (wrong)
```

---

## Advanced Testing

### **Test Without App - Use Google Play Console**
```
1. Go to https://myaccount.google.com/
2. Click "Sign in to a different account"
3. Select your test account
4. This tests if Google auth works
5. If this fails, Google Sign-In will fail in app too
```

---

### **Check Firebase Console - Are Users Created?**
```
1. Firebase Console
2. Authentication → Users
3. After clicking Google Sign-In, check if your account appears
4. If it appears = configuration correct
5. If doesn't appear = something's wrong
```

---

### **Enable Debug Mode in app**
Edit `lib/screens/auth/login_screen.dart`:
```dart
// Add after onClick handler:
print("Google button clicked!");
await auth.googleLogin();
print("Google login completed!");
print("Is logged in: ${auth.isLoggedIn}");
print("Error: ${auth.error}");
```

---

## Quick Checklist ✅

- [ ] Pop-ups allowed in Chrome for localhost
- [ ] Google enabled in Firebase Authentication
- [ ] Web app registered in Firebase Console
- [ ] Redirect URIs added to Google Cloud Console  
- [ ] App is running on http://localhost:5000 (not HTTPS)
- [ ] FirebaseOptions.web configured properly
- [ ] Internet connection working
- [ ] Browser console shows no red errors

---

## What to Report If Still Not Working

When you click Google Sign-In button and it fails:

1. **Take a screenshot of the error**
2. **Open F12 → Console tab**
3. **Copy the red error message**
4. **Report:**
   - What error message you see
   - Whether the button responds at all
   - Whether a popup opens
   - What you see in console

---

## Reset Steps (If Everything Fails)

```bash
# 1. Clear everything
flutter clean
rm -rf build/
rm -rf .flutter-plugins-dependencies
rm -rf .firebase_temp

# 2. Reinstall
flutter pub get

# 3. Restart
flutter run -d chrome

# 4. Try Google Sign-In
```

---

## Key Points for Web Google Sign-In:

1. **allowPopups** - Need enabled in browser
2. **OAuth Consent Screen** - Need configured in Google Cloud
3. **Redirect URIs** - Must include localhost URIs
4. **Firebase Web App** - Must be registered
5. **Google Provider** - Must be enabled in Firebase Auth

All 5 need to be correct for it to work!

---

## File Changes Made:

1. **firebase_service.dart** - Now uses `signInWithPopup()` first (Web-friendly)
2. **auth_provider.dart** - Better error messages for all cases

---

## Still Not Working?

Post the exact error message from the console (F12) and I'll help fix it! 🚀
