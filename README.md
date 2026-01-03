# IRTA Forms Management System

A Flutter application for managing International Road Transport Agreement (IRTA) forms, supporting Web, Mobile (iOS/Android), and Windows desktop platforms.

## 🌐 Live Web App

The web version is hosted on GitHub Pages: [View Live App](https://mohagy.github.io/IRTA_Forms/)

## 📱 Features

- ✅ **Multi-platform Support**: Web, iOS, Android, Windows
- ✅ **Firebase Integration**: Authentication, Firestore, Storage
- ✅ **Role-Based Access Control**: Admin, Officer, Applicant roles
- ✅ **User Management**: Complete CRUD operations for users
- ✅ **Roles & Permissions**: Dynamic role and permission management
- ✅ **Application Management**: Create, view, and manage IRTA applications
- ✅ **Real-time Updates**: Live data synchronization with Firestore

## 🏗️ Project Structure

```
IRTA_Forms/
├── irta_forms_app/          # Flutter application
│   ├── lib/                 # Source code
│   ├── web/                 # Web assets
│   ├── android/             # Android configuration
│   ├── ios/                 # iOS configuration
│   └── windows/             # Windows configuration
├── dashboard_mockup.html    # Design reference
└── applicant_workflow_mockup.html
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.38.2 or later)
- Dart SDK (3.10.0 or later)
- Firebase account and project
- Node.js and npm (for Firebase CLI)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohagy/IRTA_Forms.git
   cd IRTA_Forms/irta_forms_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Follow instructions in `irta_forms_app/FIREBASE_SETUP.md`
   - Configure Firebase: `flutterfire configure`
   - Enable Authentication and Firestore in Firebase Console

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run
   
   # Windows
   flutter run -d windows
   ```

## 📚 Documentation

- [Firebase Setup Guide](irta_forms_app/FIREBASE_SETUP.md)
- [Admin Credentials Setup](irta_forms_app/ADMIN_SETUP.md)
- [User Management Guide](irta_forms_app/USER_SYNC_GUIDE.md)
- [Roles & Permissions Setup](irta_forms_app/SEED_ROLES.md)
- [Web Run Instructions](irta_forms_app/WEB_RUN_INSTRUCTIONS.md)

## 🔐 Admin Setup

1. Create admin user in Firebase Console
2. Set role to "admin" in Firestore `users` collection
3. See `irta_forms_app/CREATE_ADMIN_USER.md` for details

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Database**: Firebase Firestore
- **Authentication**: Firebase Authentication
- **Storage**: Firebase Storage
- **State Management**: Provider
- **Routing**: go_router
- **File Handling**: file_picker

## 📄 License

Copyright © 2024 IRTA Administration. All rights reserved.

## 👤 Author

**Nathan Heart**  
Email: nathonheart@gmail.com  
GitHub: [@mohagy](https://github.com/mohagy)


