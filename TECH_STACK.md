# Paw Connect - Tech Stack Documentation

## Overview
Paw Connect is a Flutter-based mobile application for pet adoption and fostering, connecting pet owners with potential adopters in a user-friendly platform.

## 🏗️ Architecture
- **Pattern**: MVC (Model-View-Controller)
- **State Management**: StatefulWidget with setState()
- **Navigation**: Traditional Navigator-based routing
- **Data Storage**: Local storage using SharedPreferences

## 📱 Core Technologies

### Frontend Framework
- **Flutter** ^3.11.5
- **Dart** (SDK ^3.11.5)
- **Material Design** UI Components

### Key Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
  image_picker: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## 📁 Project Structure

```
lib/
├── constants/           # App constants (colors, styles)
├── models/             # Data models
│   ├── pet.dart
│   ├── user.dart
│   └── message.dart
├── pages/              # UI screens
│   ├── adopt_companion_page.dart
│   ├── all_pets_page.dart
│   ├── favorites_page.dart
│   ├── login_page.dart
│   ├── pet_list_page.dart
│   └── ...
├── services/           # Business logic & data management
│   ├── auth_service.dart
│   ├── favorites_service.dart
│   ├── pet_storage_service.dart
│   ├── adoption_request_service.dart
│   └── message_service.dart
├── widgets/            # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── custom_bottom_nav_bar.dart
│   └── paw_logo.dart
└── main.dart          # App entry point
```

## 🔧 Core Services

### Authentication Service (`auth_service.dart`)
- User registration and login
- Session management
- Password reset functionality
- Local user data storage

### Pet Storage Service (`pet_storage_service.dart`)
- CRUD operations for pet listings
- Image handling (base64 encoding)
- Category-based filtering
- Search functionality

### Favorites Service (`favorites_service.dart`)
- User-specific favorites management
- Persistent storage using SharedPreferences
- Real-time favorites list updates

### Message Service (`message_service.dart`)
- In-app messaging system
- Conversation management
- Message history

### Adoption Request Service (`adoption_request_service.dart`)
- Adoption request processing
- Request status tracking
- Notification management

## 🎨 UI Components

### Custom Widgets
- **CustomButton**: Reusable button with consistent styling
- **CustomTextField**: Input fields with validation
- **CustomBottomNavBar**: Navigation bar component
- **PawLogo**: App logo component

### Design System
- **AppColors**: Centralized color scheme
- **AppStyles**: Text styling and themes
- Material Design principles

## 💾 Data Management

### Storage Strategy
- **SharedPreferences**: For user sessions, favorites, and settings
- **Local Storage**: Pet listings and user data
- **Base64 Encoding**: Image storage in local database

### Data Models
- **Pet**: Pet information (name, breed, age, image, etc.)
- **User**: User profile and authentication data
- **Message**: Chat messages and conversation data

## 🚀 Features

### Core Functionality
- User authentication (login/register)
- Pet browsing and search
- Category filtering (Dogs, Cats, Birds, Rabbits)
- Favorites system
- Adoption requests
- In-app messaging
- Image upload and display

### UI/UX Features
- Responsive grid layouts
- Image carousels
- Form validation
- Loading states
- Error handling
- Navigation between screens

## 🔐 Security Considerations
- Local data storage (no network communication)
- Basic input validation
- Session management through SharedPreferences

## 📱 Platform Support
- **Android**: Primary target platform
- **iOS**: Compatible (with proper configuration)
- **Web**: Potential support (untested)

## 🛠️ Development Tools
- **Flutter Lints**: Code quality and style enforcement
- **Flutter Test**: Unit testing framework
- **Hot Reload**: Development efficiency

## 📦 Build & Deployment
- **APK Size**: ~48.7MB (release build)
- **Build Tool**: Flutter build system
- **Target**: Android APK distribution

## 🔮 Future Enhancements
- Firebase integration for backend services
- Real-time messaging
- Push notifications
- Cloud image storage
- Advanced search filters
- User profiles with ratings

---

*Last Updated: December 2024*
*Version: 1.0.0+1*
