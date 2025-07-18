# SisterCheck Flutter Mobile App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)

**Cross-platform mobile application for women's health management**

</div>

## 📱 Overview

The SisterCheck Flutter app is a comprehensive mobile application designed to provide women with easy access to healthcare services, AI-powered diagnostic tools, and health management features. The app serves both patients and healthcare providers with a modern, intuitive interface.

## ✨ Features

### 🏥 Patient Features
- **User Registration & Authentication**: Secure login with email/password or social login
- **Health Profile Management**: Personal health information and medical history
- **AI-Powered Diagnostics**: Ovarian cyst prediction and risk assessment
- **Appointment Scheduling**: Book and manage healthcare appointments
- **Health Records**: View and manage medical records and test results
- **Medication Reminders**: Track medications and set reminders
- **Symptom Tracker**: Log and monitor health symptoms over time
- **Emergency Contacts**: Quick access to emergency healthcare contacts

### 👩‍⚕️ Provider Features
- **Provider Dashboard**: Comprehensive patient management interface
- **Patient Records**: Access and update patient health information
- **Diagnostic Tools**: AI-assisted diagnostic recommendations
- **Care Coordination**: Manage patient care plans and follow-ups
- **Analytics Dashboard**: View patient statistics and health trends
- **Communication Tools**: Secure messaging with patients

### 🤖 AI Integration
- **Real-time Predictions**: Instant ovarian cyst risk assessment
- **Treatment Recommendations**: AI-powered treatment suggestions
- **Risk Scoring**: Personalized health risk evaluation
- **Clinical Decision Support**: Evidence-based clinical recommendations

### 🔗 Healthcare Interoperability
- **FHIR Integration**: Standard healthcare data exchange
- **OpenHIE Support**: Health information exchange capabilities
- **DHIS2 Connectivity**: Health management system integration
- **Data Export**: Export health data in standard formats

### 🌐 Additional Features
- **Offline Support**: Core features work without internet connection
- **Multi-language**: English and Swahili language support
- **Voice Input**: Speech-to-text for hands-free data entry
- **Location Services**: Find nearby healthcare facilities
- **Push Notifications**: Important health reminders and updates
- **Dark Mode**: Comfortable viewing in low-light conditions

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.8.1** - Cross-platform UI framework
- **Dart 3.8.1** - Programming language

### State Management
- **Riverpod 2.6.1** - State management solution
- **Provider** - Dependency injection

### UI/UX
- **Material Design 3** - Modern design system
- **Cupertino Icons** - iOS-style icons
- **Flutter SpinKit** - Loading animations

### Networking & APIs
- **HTTP 1.4.0** - REST API communication
- **Internet Connection Checker** - Network status monitoring
- **Shared Preferences** - Local data storage

### Location & Maps
- **Google Maps Flutter** - Interactive maps
- **Location** - GPS and location services

### Voice & Accessibility
- **Speech to Text** - Voice input capabilities
- **Flutter TTS** - Text-to-speech functionality

### File Handling
- **File Picker** - Document and image selection

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── constants/
│   └── screens_path.dart     # Screen route constants
├── models/
│   ├── sistercheck.dart      # Core data models
│   └── user_model.dart       # User-related models
├── plugins/
│   ├── app_provider.dart     # App-wide providers
│   ├── network_constant.dart # API endpoints
│   ├── network_provider.dart # Network service providers
│   ├── theme/                # App theming
│   └── utils/                # Utility functions
├── screens/
│   ├── auth/                 # Authentication screens
│   ├── dashboard/            # Dashboard screens
│   ├── health/               # Health-related screens
│   ├── profile/              # Profile management
│   └── settings/             # App settings
├── services/
│   ├── care_template_service.dart    # Care template API
│   ├── crystal_ai_service.dart       # AI service integration
│   └── doctor_dashboard_service.dart # Provider services
└── widgets/
    ├── auth_wrapper.dart     # Authentication wrapper
    ├── custom_bottom_appbar.dart # Custom navigation
    └── logout_confirmation_sheet.dart # Logout dialog
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **Android Studio** or **VS Code**
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/sistercheck.git
   cd sistercheck
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Edit environment variables
   nano .env
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome  # Web
   ```

### Environment Configuration

Create a `.env` file with the following variables:

```env
# API Configuration
API_BASE_URL=http://localhost:3000
AI_SERVICE_URL=http://localhost:5001

# Google Services
GOOGLE_MAPS_API_KEY=your_google_maps_api_key

# App Configuration
APP_NAME=SisterCheck
APP_VERSION=1.0.0
DEBUG_MODE=true
```

## 📱 Platform Support

### Android
- **Minimum SDK**: API 21 (Android 5.0)
- **Target SDK**: API 33 (Android 13)
- **Architecture**: ARM64, x86_64

### iOS
- **Minimum Version**: iOS 12.0
- **Target Version**: iOS 16.0
- **Devices**: iPhone, iPad

### Web
- **Browsers**: Chrome, Firefox, Safari, Edge
- **Features**: Responsive design, PWA support

## 🔧 Development

### Code Style

We follow the official Dart style guide and use `flutter_lints` for code quality:

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run lints
flutter pub run flutter_lints
```

### Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🔐 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Data Encryption**: Sensitive data encryption at rest
- **Secure Storage**: Encrypted local storage for sensitive data
- **Network Security**: HTTPS-only API communication
- **Biometric Authentication**: Fingerprint/Face ID support
- **Session Management**: Automatic session timeout and renewal

## 🌍 Internationalization

The app supports multiple languages:

- **English** (default)
- **Swahili** (Kiswahili)

### Adding New Languages

1. Create translation files in `assets/translations/`
2. Add language codes to `lib/constants/languages.dart`
3. Update the language selector in settings

## 📊 Analytics & Monitoring

- **Crash Reporting**: Automatic crash detection and reporting
- **User Analytics**: Anonymous usage statistics
- **Performance Monitoring**: App performance metrics
- **Error Tracking**: Detailed error logging and reporting

## 🔄 State Management

We use Riverpod for state management with the following providers:

- **AuthProvider**: User authentication state
- **UserProvider**: User profile and preferences
- **HealthProvider**: Health data and records
- **NetworkProvider**: Network connectivity status
- **ThemeProvider**: App theme and appearance

## 🎨 UI/UX Guidelines

### Design System
- **Primary Color**: Healthcare blue (#2196F3)
- **Secondary Color**: Accent green (#4CAF50)
- **Error Color**: Warning red (#F44336)
- **Success Color**: Success green (#4CAF50)

### Typography
- **Headings**: Roboto Bold
- **Body Text**: Roboto Regular
- **Monospace**: Roboto Mono

### Icons
- **Material Icons**: Primary icon set
- **Cupertino Icons**: iOS-style icons
- **Custom Icons**: App-specific icons

## 🚀 Deployment

### Android Play Store

1. **Build release APK**
   ```bash
   flutter build appbundle --release
   ```

2. **Sign the bundle**
   ```bash
   jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore ~/upload-keystore.jks build/app/outputs/bundle/release/app-release.aab upload
   ```

3. **Upload to Play Console**

### iOS App Store

1. **Build iOS app**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

3. **Upload to App Store Connect**

### Web Deployment

1. **Build web app**
   ```bash
   flutter build web --release
   ```

2. **Deploy to hosting service**
   ```bash
   # Example: Firebase Hosting
   firebase deploy
   ```

## 🐛 Troubleshooting

### Common Issues

1. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **iOS Build Issues**
   ```bash
   cd ios
   pod install
   cd ..
   flutter run
   ```

3. **Android Build Issues**
   ```bash
   flutter doctor
   flutter clean
   flutter pub get
   ```

### Debug Mode

Enable debug mode for detailed logging:

```dart
// In main.dart
const bool kDebugMode = true;
```

## 📚 API Documentation

The app integrates with several APIs:

- **Backend API**: User management and business logic
- **AI Service**: Machine learning predictions
- **Google Maps API**: Location services
- **FHIR API**: Healthcare data exchange

See [API Documentation](../docs/api-docs.md) for detailed endpoint information.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Development Guidelines

- Follow Dart style guide
- Write unit tests for new features
- Update documentation
- Test on multiple platforms

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🆘 Support

- **Documentation**: [User Guide](../docs/user-guide.md)
- **Issues**: [GitHub Issues](https://github.com/your-username/sistercheck/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/sistercheck/discussions)
- **Email**: support@sistercheck.com

---

<div align="center">

**Built with ❤️ for Women's Health**

[Privacy Policy](../docs/privacy.md) | [Terms of Service](../docs/terms.md)

</div> 