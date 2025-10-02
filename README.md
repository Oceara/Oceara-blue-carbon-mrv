# Oceara - Blue Carbon MRV

A Flutter application for Blue Carbon Monitoring, Reporting, and Verification (MRV) with carbon credit trading capabilities.

## Features

### 🌱 For Land Owners
- **Land Registration**: Pin land locations on interactive Google Maps
- **Satellite Data Processing**: AI-powered carbon stock estimation
- **Credit Tracking**: Monitor carbon credits earned from your lands
- **Certificate Generation**: Download carbon credit certificates
- **Real-time Updates**: Get notified of land cover changes

### 💰 For Buyers
- **Credit Marketplace**: Browse available carbon credits
- **Pricing Information**: Transparent pricing for carbon credits
- **Land Information**: View details of lands offering credits
- **Purchase Management**: Easy credit purchasing process

### 👨‍💼 For Administrators
- **Land Management**: Approve/reject land submissions
- **User Management**: Monitor all registered users
- **Registry Management**: Track approved lands and credits
- **Monitoring Dashboard**: Real-time analytics and insights

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Charts**: Syncfusion Flutter Charts
- **Storage**: SharedPreferences
- **HTTP**: HTTP package for API calls

## Project Structure

```
lib/
├── models/          # Data models (User, Land, Role)
├── screens/         # UI screens
├── services/        # Business logic services
├── providers/       # State management
└── widgets/         # Reusable UI components
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Google Maps API Key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/oceara-blue-carbon-mrv.git
cd oceara-blue-carbon-mrv
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Google Maps:
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Update `android/app/src/main/AndroidManifest.xml` with your API key
   - Update `ios/Runner/Info.plist` with your API key

4. Run the app:
```bash
flutter run
```

## API Configuration

### Android
Add your Google Maps API key to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_API_KEY_HERE"/>
```

### iOS
Add your Google Maps API key to `ios/Runner/Info.plist`:
```xml
<key>GMSApiKey</key>
<string>YOUR_API_KEY_HERE</string>
```

## Google Site Verification

To verify your website with Google Search Console:

### Method 1: Meta Tag (Recommended)
1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add your property (website URL)
3. Choose "HTML tag" verification method
4. Copy the verification code from Google
5. Replace `YOUR_GOOGLE_VERIFICATION_CODE` in `web/index.html` with your actual code:
```html
<meta name="google-site-verification" content="YOUR_ACTUAL_VERIFICATION_CODE">
```

### Method 2: HTML File
1. In Google Search Console, choose "HTML file" verification method
2. Download the verification file
3. Replace the content in `web/google-site-verification.html` with your verification code
4. Deploy the file to your web root

### Web Deployment
For GitHub Pages deployment:
```bash
flutter build web
# Deploy the build/web folder to your hosting platform
```

## User Roles

1. **Land Owner**: Register lands, track carbon credits
2. **Buyer**: Purchase carbon credits from available lands
3. **Admin**: Manage users, approve lands, monitor system

## Features Overview

### Land Registration Process
1. User selects land location on map
2. Satellite data processing simulation
3. AI carbon stock estimation
4. Credit calculation and display
5. Admin approval workflow

### Carbon Credit System
- Real-time credit calculation
- Historical credit tracking
- Certificate generation
- Marketplace integration

### Admin Dashboard
- Pending land approvals
- User management
- Registry maintenance
- Monitoring analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.

---

**Oceara** - Empowering Blue Carbon Conservation through Technology