# Firebase Setup Script for IRTA Forms App
# Run this script to configure Firebase for the Flutter project

Write-Host "Firebase Setup for IRTA Forms App" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Add paths to PATH for this session
$env:Path += ";$env:APPDATA\npm;C:\Users\Administrator\AppData\Local\Pub\Cache\bin"

# Check if Firebase CLI is installed
Write-Host "Checking Firebase CLI installation..." -ForegroundColor Yellow
try {
    $firebaseVersion = firebase --version
    Write-Host "Firebase CLI version: $firebaseVersion" -ForegroundColor Green
} catch {
    Write-Host "Firebase CLI not found in PATH. Please ensure it's installed." -ForegroundColor Red
    Write-Host "Install it with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}

# Check if FlutterFire CLI is installed
Write-Host "Checking FlutterFire CLI installation..." -ForegroundColor Yellow
try {
    $flutterfireVersion = flutterfire --version
    Write-Host "FlutterFire CLI is installed" -ForegroundColor Green
} catch {
    Write-Host "FlutterFire CLI not found. Installing..." -ForegroundColor Yellow
    dart pub global activate flutterfire_cli
    Write-Host "FlutterFire CLI installed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 1: Login to Firebase" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "You need to login to Firebase. This will open a browser window." -ForegroundColor Yellow
Write-Host "Press any key to continue with Firebase login..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

firebase login

Write-Host ""
Write-Host "Step 2: Configure FlutterFire" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Now we'll configure Firebase for your Flutter project." -ForegroundColor Yellow
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Navigate to project directory
Set-Location $PSScriptRoot

# Run FlutterFire configure
flutterfire configure

Write-Host ""
Write-Host "Firebase setup complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update lib/main.dart to uncomment Firebase initialization" -ForegroundColor Yellow
Write-Host "2. The firebase_options.dart file should now be generated" -ForegroundColor Yellow

