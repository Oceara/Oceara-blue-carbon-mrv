# Google Maps Setup Guide

## Current Issues and Solutions

### 1. API Key Configuration ✅
- **Android**: API key is configured in `android/app/src/main/AndroidManifest.xml`
- **iOS**: API key is configured in `ios/Runner/Info.plist`
- **Current Key**: `AIzaSyCr7OCUUszubXnvzOO5T6-bYOhXGm0o25A`

### 2. Common Issues and Solutions

#### Issue: Blank/White Map
**Possible Causes:**
1. **API Key Restrictions**: The API key might be restricted to specific apps/IPs
2. **Billing Not Enabled**: Google Maps requires billing to be enabled
3. **Maps SDK Not Enabled**: Required APIs might not be enabled

**Solutions:**
1. **Check Google Cloud Console**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Navigate to "APIs & Services" > "Credentials"
   - Find your API key and check restrictions

2. **Enable Required APIs**:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (if using places)
   - Geocoding API (if using geocoding)

3. **Enable Billing**:
   - Go to "Billing" in Google Cloud Console
   - Link a payment method (required for Maps API)

4. **Check API Key Restrictions**:
   - For development: Add your app's package name and SHA-1 fingerprint
   - For production: Use proper restrictions

#### Issue: Maps Not Loading on Emulator
**Solutions:**
1. **Use Google APIs Emulator**:
   - Create AVD with Google APIs (not just Android)
   - Enable Google Play Services

2. **Check Emulator Settings**:
   - Enable location services
   - Check internet connection

3. **Alternative Testing**:
   - Test on physical device
   - Use web version for testing

### 3. Step-by-Step Setup

#### Step 1: Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable billing

#### Step 2: Enable APIs
1. Go to "APIs & Services" > "Library"
2. Search and enable:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API

#### Step 3: Create API Key
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated key

#### Step 4: Configure Restrictions (Recommended)
1. Click on your API key
2. Under "Application restrictions":
   - For Android: Add package name and SHA-1 fingerprint
   - For iOS: Add bundle identifier
3. Under "API restrictions": Select "Restrict key" and choose the APIs you enabled

#### Step 5: Update Your App
1. Replace the API key in:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`

### 4. Testing Your Setup

#### Check API Key Validity
```bash
# Test API key with curl
curl "https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=YOUR_API_KEY"
```

#### Debug in Flutter
1. Check console logs for errors
2. Look for "Google Maps initialized successfully" message
3. Check for any API key related errors

### 5. Troubleshooting Commands

#### Get SHA-1 Fingerprint (Android)
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (if using)
keytool -list -v -keystore path/to/your/keystore.jks -alias your-key-alias
```

#### Check Package Name
- **Android**: Check `android/app/build.gradle` for `applicationId`
- **iOS**: Check `ios/Runner/Info.plist` for `CFBundleIdentifier`

### 6. Current Configuration Status

✅ **API Key**: Configured in both Android and iOS  
✅ **Permissions**: Internet, Location permissions added  
✅ **Dependencies**: google_maps_flutter added  
⚠️ **Billing**: Needs to be enabled in Google Cloud Console  
⚠️ **API Restrictions**: May need to be configured  

### 7. Next Steps

1. **Enable Billing** in Google Cloud Console
2. **Enable Required APIs** (Maps SDK for Android/iOS)
3. **Configure API Key Restrictions** for your app
4. **Test on Physical Device** if emulator issues persist
5. **Check Console Logs** for specific error messages

### 8. Alternative Testing

If Google Maps continues to have issues:
1. **Use Web Version**: Test the web build with Google Maps
2. **Physical Device**: Test on actual Android/iOS device
3. **Different API Key**: Create a new API key with proper configuration
4. **Check Quotas**: Ensure you haven't exceeded API quotas

## Support

If issues persist:
1. Check Google Cloud Console for error logs
2. Verify billing is enabled
3. Ensure all required APIs are enabled
4. Test with a fresh API key
