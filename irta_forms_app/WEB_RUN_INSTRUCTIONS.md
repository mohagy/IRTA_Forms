# Running IRTA Forms App on Web

## Quick Start

### Step 1: Enable Web Support (if not already enabled)
```powershell
cd C:\xampp2\htdocs\IRTA_Forms\irta_forms_app
flutter config --enable-web
```

### Step 2: Check Web Devices
```powershell
flutter devices
```
You should see Chrome or Edge listed as available devices.

### Step 3: Run on Web
```powershell
flutter run -d chrome
```

Or if you prefer Edge:
```powershell
flutter run -d edge
```

Or to let Flutter choose automatically:
```powershell
flutter run -d web-server
```

## Development Mode

### Hot Reload
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Run with Specific Port
```powershell
flutter run -d chrome --web-port=8080
```

Then access at: `http://localhost:8080`

## Build for Production

### Build Web App
```powershell
flutter build web
```

The built files will be in: `build/web/`

### Deploy to Firebase Hosting (if configured)
```powershell
firebase deploy --only hosting
```

### Serve Built Files Locally
```powershell
cd build/web
# Use any local server, for example with Python:
python -m http.server 8080
# Or with Node.js http-server:
npx http-server -p 8080
```

## Troubleshooting

### If Chrome/Edge not detected:
1. Make sure Chrome or Edge is installed
2. Check Flutter web support: `flutter config --enable-web`
3. Verify: `flutter doctor -v`

### If you get build errors:
1. Clean build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Try again: `flutter run -d chrome`

### Firebase Web Configuration
Make sure `firebase_options.dart` exists and is configured for web platform.

## Default URLs

- Development: `http://localhost:XXXX` (port shown in terminal)
- Default port: Usually 50000+ range
- Web server mode: `http://localhost:8080` (if using --web-port)

## Notes

- First run may take longer as Flutter builds the web app
- Hot reload works great for web development
- Use Chrome DevTools (F12) for debugging
- Check browser console for any errors


