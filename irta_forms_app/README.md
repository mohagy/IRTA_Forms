# IRTA Forms Management System

A Flutter application for managing International Road Transport Agreement (IRTA) forms, supporting Web, Mobile (iOS/Android), and Windows desktop platforms.

## Project Status

**Phase 1: Project Setup & Core Infrastructure** ✅ **COMPLETE**

### Completed
- ✅ Flutter project initialized with multi-platform support (Web, Android, iOS, Windows)
- ✅ Project structure following Clean Architecture principles
- ✅ Dependencies configured (Firebase, Routing, State Management, etc.)
- ✅ Theme system matching dashboard_mockup.html design
- ✅ Core layout widgets (Sidebar, Header, MainLayout)
- ✅ Basic routing setup with go_router
- ✅ App constants and configuration

## Architecture

This project follows Clean Architecture principles with the following structure:

```
lib/
├── app/                    # App configuration and routing
├── core/                   # Core utilities and shared code
│   ├── constants/         # App-wide constants
│   ├── theme/             # Theme and styling
│   ├── utils/             # Utility functions
│   └── security/          # Security configurations
├── data/                   # Data layer
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── datasources/       # Data sources (Firebase, etc.)
├── domain/                 # Domain layer (business logic)
│   ├── entities/          # Domain entities
│   └── usecases/          # Use cases
├── presentation/           # Presentation layer (UI)
│   ├── pages/             # Screen pages
│   ├── widgets/           # Reusable widgets
│   └── providers/         # State management providers
└── services/               # Services (Auth, Storage, etc.)
```

## Design

The application design replicates the dashboard_mockup.html layout:
- **Sidebar**: Gradient sidebar with navigation items
- **Header**: Top header with title and actions
- **Main Content**: Scrollable content area
- **Colors**: Matching color scheme from the mockup
- **Typography**: System fonts matching the mockup

## Getting Started

### Prerequisites

- Flutter SDK (3.38.2 or later)
- Dart SDK (3.10.0 or later)
- Node.js and npm (for Firebase CLI)
- Firebase project (see FIREBASE_SETUP.md for setup instructions)

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Set up Firebase:
   - Follow the instructions in `FIREBASE_SETUP.md`
   - Or run the setup script: `.\setup_firebase.ps1`
   - This will configure Firebase and generate `firebase_options.dart`

3. Run the app:
```bash
# Web
flutter run -d chrome

# Mobile
flutter run

# Windows
flutter run -d windows
```

## Next Steps

### Phase 2: Authentication & User Management (TODO)
- Landing page implementation
- Registration page
- Login page
- Firebase Authentication integration
- Role-based access control
- User profile management

### Phase 3: Dashboard & Navigation (TODO)
- Dashboard page with stats
- Sidebar navigation implementation
- Page routing
- Role-based navigation visibility

### Phase 4: Application Management (TODO)
- Application list/table view
- Application detail view
- New application form (multi-step wizard)
- Document upload functionality

## Technology Stack

- **Framework**: Flutter 3.x
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Storage
- **State Management**: Provider
- **Routing**: go_router
- **HTTP**: Dio
- **PDF Generation**: pdf package
- **Local Storage**: shared_preferences

## Color Palette

The app uses a color scheme matching the dashboard mockup:
- **Primary**: #3b82f6 (Blue)
- **Sidebar Gradient**: #1e3a5f to #2c5282
- **Background**: #f8fafc
- **Text**: #1e293b (Primary), #475569 (Secondary)
- **Status Colors**: Completed (#10b981), Submitted (#f59e0b), Draft (#64748b)

## Project Structure Details

### Core Files Created

- `lib/main.dart` - Application entry point
- `lib/app/app.dart` - Main app widget
- `lib/app/routes.dart` - Route configuration
- `lib/core/theme/app_colors.dart` - Color constants
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/constants/app_constants.dart` - App constants
- `lib/presentation/widgets/sidebar.dart` - Sidebar widget
- `lib/presentation/widgets/app_header.dart` - Header widget
- `lib/presentation/widgets/main_layout.dart` - Main layout wrapper

### Placeholder Pages

- `lib/presentation/pages/landing/landing_page.dart`
- `lib/presentation/pages/registration/registration_page.dart`
- `lib/presentation/pages/login/login_page.dart`
- `lib/presentation/pages/dashboard/dashboard_page.dart`

## Contributing

This is an internal project for IRTA Forms Management. For contributions, please follow the established architecture patterns and coding standards.

## License

Copyright © 2024 IRTA Administration. All rights reserved.
