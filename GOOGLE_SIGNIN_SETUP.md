# Google Sign-In Setup Guide

## Overview
Google Sign-In has been integrated into the Oceara app alongside mobile number verification. Users can now choose between:
1. **Mobile Number + OTP** (existing method)
2. **Google Sign-In** (new method)

## Features Added

### 1. Login Screen Updates
- ✅ Added Google Sign-In button with professional styling
- ✅ Added "OR" divider between authentication methods
- ✅ Role selection dialog for Google Sign-In users
- ✅ Loading indicators during authentication
- ✅ Error handling for failed sign-ins

### 2. Authentication Flow
- ✅ Google Sign-In integration with role selection
- ✅ Automatic navigation to appropriate dashboard based on role
- ✅ User data persistence using SharedPreferences
- ✅ Seamless integration with existing AuthProvider

## Configuration Required

### 1. Google Cloud Console Setup

#### Step 1: Create/Configure Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your existing project or create a new one
3. Enable the **Google Sign-In API**

#### Step 2: Configure OAuth Consent Screen
1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" user type
3. Fill in required fields:
   - App name: "Oceara"
   - User support email: your email
   - Developer contact: your email
4. Add scopes: `email`, `profile`, `openid`
5. Add test users (for development)

#### Step 3: Create OAuth 2.0 Credentials
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Create credentials for:
   - **Android**: Add package name and SHA-1 fingerprint
   - **iOS**: Add bundle identifier
   - **Web**: For web version (optional)

### 2. Android Configuration

#### Get SHA-1 Fingerprint
```bash
# Debug keystore
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Release keystore (for production)
keytool -list -v -keystore path/to/your/keystore.jks -alias your-key-alias
```

#### Update google-services.json
1. Download `google-services.json` from Google Cloud Console
2. Place it in `android/app/` directory
3. Ensure it's added to `.gitignore` for security

#### Update build.gradle
Add to `android/app/build.gradle.kts`:
```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

### 3. iOS Configuration

#### Update GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from Google Cloud Console
2. Add it to `ios/Runner/` directory
3. Ensure it's added to `.gitignore` for security

#### Update Info.plist
Add URL scheme to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

### 4. Web Configuration (Optional)

For web deployment, add to `web/index.html`:
```html
<script src="https://accounts.google.com/gsi/client" async defer></script>
```

## Testing

### 1. Development Testing
- Use test users added to OAuth consent screen
- Test on both Android and iOS devices/emulators
- Verify role selection and navigation

### 2. Production Deployment
- Update OAuth consent screen to "Production"
- Use release keystore SHA-1 fingerprint
- Test with real Google accounts

## Troubleshooting

### Common Issues

#### 1. "Sign in failed" Error
- Check SHA-1 fingerprint matches Google Cloud Console
- Verify package name is correct
- Ensure Google Sign-In API is enabled

#### 2. "Invalid client" Error
- Verify OAuth client configuration
- Check bundle identifier (iOS) or package name (Android)
- Ensure google-services.json is in correct location

#### 3. "Access blocked" Error
- Add test users to OAuth consent screen
- Check app verification status
- Verify scopes are correctly configured

### Debug Steps
1. Check console logs for specific error messages
2. Verify Google Cloud Console configuration
3. Test with different Google accounts
4. Check network connectivity

## Security Considerations

### 1. API Key Protection
- Never commit `google-services.json` or `GoogleService-Info.plist` to version control
- Use environment variables for sensitive configuration
- Regularly rotate API keys

### 2. User Data
- Google Sign-In provides email and profile information
- User role is selected during sign-in process
- All user data is stored locally using SharedPreferences

## Current Status

✅ **Implementation Complete**:
- Google Sign-In button added to login screen
- Role selection dialog implemented
- Authentication flow integrated with AuthProvider
- Professional UI styling applied
- Error handling and loading states added

⚠️ **Configuration Required**:
- Google Cloud Console setup
- OAuth credentials configuration
- SHA-1 fingerprint setup for Android
- Bundle identifier setup for iOS

## Next Steps

1. **Configure Google Cloud Console** with your project details
2. **Add SHA-1 fingerprint** for Android
3. **Download configuration files** (google-services.json, GoogleService-Info.plist)
4. **Test authentication flow** on both platforms
5. **Deploy to production** with proper credentials

## Support

For issues with Google Sign-In:
1. Check Google Cloud Console for error logs
2. Verify OAuth configuration
3. Test with different Google accounts
4. Check device/emulator setup
