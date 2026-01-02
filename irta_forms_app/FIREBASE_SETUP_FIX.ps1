# Firebase Setup with Execution Policy Bypass
# Run this: Get-Content .\FIREBASE_SETUP_FIX.ps1 | PowerShell -ExecutionPolicy Bypass

# Bypass execution policy for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Add paths
$env:Path += ";$env:APPDATA\npm;C:\Users\Administrator\AppData\Local\Pub\Cache\bin"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Firebase Setup for IRTA Forms App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Firebase CLI
Write-Host "Checking Firebase CLI..." -ForegroundColor Yellow
try {
    firebase --version
    Write-Host "Firebase CLI is ready" -ForegroundColor Green
} catch {
    Write-Host "Firebase CLI not found. Please install with: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "STEP 1: Login to Firebase" -ForegroundColor Green
Write-Host "This will open your browser for authentication..." -ForegroundColor Yellow
Write-Host ""

firebase login

Write-Host ""
Write-Host "STEP 2: Configure FlutterFire" -ForegroundColor Green
Write-Host "This will set up Firebase for your Flutter project..." -ForegroundColor Yellow
Write-Host ""

flutterfire configure

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update lib/main.dart to uncomment Firebase initialization" -ForegroundColor Yellow
Write-Host "2. Enable Authentication and Firestore in Firebase Console" -ForegroundColor Yellow

